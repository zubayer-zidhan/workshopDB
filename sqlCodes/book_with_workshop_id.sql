DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS book_with_workshop_id(IN wid INT, IN uid INT, IN bdate DATE)
BEGIN
    -- Declarations
    DECLARE num_slots INT;
    DECLARE isLocked INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

    -- Starting the transaction
    START TRANSACTION;

    -- Selecting the number of available slots in a given workshop
    -- "for update" grants exclusive lock to the slots-availability table
      -- TODO: Need to lock the temp table ???
    SELECT GET_LOCK("workshops_lock", 5) INTO isLocked;

    select available_slots into num_slots
    from slots_availability
    where workshop_id = wid and date = bdate;
    

    -- if slots are available, then book   
    IF(num_slots > 0) THEN
        UPDATE slots_availability
        SET available_slots = available_slots - 1
        WHERE workshop_id = wid AND DATE = bdate;

        -- TODO: Release locks
        -- 10 = SUCCESS
        SELECT 10; 
        SELECT RELEASE_LOCK("workshops_lock");

        -- Commit the changes to the database, release the exclusive lock on slots_availability
        COMMIT;

        -- Insert into bookings table doesn't require exclusive lock
        INSERT INTO bookings(workshop_id, user_id, booking_date, date_created) values(wid, uid, bdate, now());
       
    -- TODO: If no slots, then ROLLBACK
    ELSEIF (num_slots = 0) THEN
        -- Error encountered, rollback, release locks
        -- 20 = Slots Full
        SELECT 20; 
        SELECT RELEASE_LOCK("workshops_lock");
        -- Error encountered, rollback, release locks
        ROLLBACK;
        -- SIGNAL SQLSTATE '45000'
        -- SET MESSAGE_TEXT = 'There are no slots available for booking on the given date at the specified workshop.';
    ELSE
		-- 30 = SOME OTHER ERROR
		SELECT 30;
		SELECT RELEASE_LOCK("workshops_lock");
        ROLLBACK;

    end if;

    -- select * from bookings;
    -- select * from slots_availability;
END $$
DELIMITER ;






















-- ************************ LOCKING IS NOT ALLOWED IN STORED PROCEDURE *************************
-- DELIMITER $$
-- CREATE PROCEDURE IF NOT EXISTS book1(IN wid INT, IN uid INT, IN bdate DATE)
-- BEGIN
--     DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

--     START TRANSACTION;

--     LOCK TABLES slots_availability WRITE;
   
--     if(0 < (select available_slots from slots_availability where workshop_id = wid and date = bdate) ) then 
--         update slots_availability
--         set
--         available_slots = available_slots-1
--         where
--         workshop_id = wid;

--         UNLOCK TABLES;

--         insert into bookings(workshop_id, user_id, booking_date, date_created) values(wid, uid, bdate, now());
       
--     else
--         SIGNAL SQLSTATE '45000'
--         SET MESSAGE_TEXT = 'There are no slots available for booking on the given date at the specified workshop.';
--     end if;

--     UNLOCK TABLES;

--     select * from bookings;
--     select * from slots_availability;
-- END $$
-- DELIMITER ;
