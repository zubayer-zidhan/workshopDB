DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS book1(IN wid INT, IN uid INT, IN bdate DATE)
BEGIN
    -- Declarations
    DECLARE num_slots INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

    -- Starting the transaction
    START TRANSACTION;

    -- Selecting the number of available slots in a given workshop
    -- "for update" grants exclusive lock to the slots-availability table
    select available_slots into num_slots
    from slots_availability
    where workshop_id = wid and date = bdate
    for update;
   

    -- if slots are available, then book   
    if(num_slots > 0) then 
        update slots_availability
        set available_slots = available_slots - 1
        where workshop_id = wid and date = bdate;

        -- Commit the changes to the database
        COMMIT;

        -- Insert into bookings table doesn't require exclusive lock
        insert into bookings(workshop_id, user_id, booking_date, date_created) values(wid, uid, bdate, now());
       
    else
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'There are no slots available for booking on the given date at the specified workshop.';
    end if;

    select * from bookings;
    select * from slots_availability;
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
