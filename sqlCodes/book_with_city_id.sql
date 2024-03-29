DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS book_with_city_id(IN cid INT, IN uid INT, IN bdate DATE)
BEGIN
    -- Declarations
    DECLARE wid INT;
    DECLARE num_zeros INT;
    DECLARE total_rows INT;
    DECLARE isLocked INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

    -- Find workshops in a city
	START TRANSACTION;

    -- Lock temporary table
	SELECT GET_LOCK("same_city_workshops_lock", 5) INTO isLocked;
    CREATE TEMPORARY TABLE same_city_workshops (SELECT * FROM slots_availability WHERE DATE = bdate AND workshop_id IN (
        SELECT id FROM workshops WHERE city_id = cid
    ));

    -- Count total number of workshops with zero slots 
    SELECT count(*) INTO num_zeros FROM same_city_workshops WHERE available_slots = 0;

    -- Count total number of workshops with a given city_id
    SELECT count(*) INTO total_rows FROM same_city_workshops;


    -- If there are workshops with more than zero slots left, insert into booking
    IF (num_zeros < total_rows) THEN
        -- Select 1 wid from same_city_workshops
        SELECT workshop_id INTO wid FROM same_city_workshops WHERE available_slots > 0 AND DATE = bdate LIMIT 0, 1;

        -- TODO: Get lock on slots_availability table
        UPDATE slots_availability
        SET available_slots = available_slots - 1
        WHERE workshop_id = wid AND DATE = bdate;

        -- TODO: Release locks
        -- 10 = SUCCESS
        SELECT 10; 
        SELECT RELEASE_LOCK("same_city_workshops_lock");
        COMMIT;
        
        INSERT INTO bookings(workshop_id, user_id, booking_date, date_created) VALUES (wid, uid, bdate, now());
        
    -- TODO: If no slots, then ROLLBACK
    ELSEIF (num_zeros = total_rows and total_rows != 0) THEN
        -- Error encountered, rollback, release locks
        -- 20 = Slots Full
        SELECT 20; 
        SELECT RELEASE_LOCK("same_city_workshops_lock");
        ROLLBACK;
        -- SIGNAL SQLSTATE '45000'
        -- SET MESSAGE_TEXT = 'There are no slots available for booking on the given date in your city.';
	ELSE
		-- 30 = SOME OTHER ERROR
		SELECT 30;
		SELECT RELEASE_LOCK("same_city_workshops_lock");
        ROLLBACK;
    END IF;
	DROP TABLE IF EXISTS same_city_workshops;  
END $$
DELIMITER ;
