-- Insertion into slots_availability
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS createSlots()
BEGIN
TRUNCATE slots_availability;
INSERT INTO slots_availability (workshop_id, date, available_slots) 
SELECT id, CURDATE() + INTERVAL 1 DAY, total_slots
FROM workshops;
END $$
DELIMITER ;

-- Afterwards,
-- Updating slots_availability regularly to reset available_slots, and change date to be the next day
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS updateSlots()
BEGIN
UPDATE slots_availability
SET
    date = CURDATE() + INTERVAL 1 DAY,
    available_slots = (SELECT total_slots FROM workshops WHERE id = workshop_id);
END $$
DELIMITER ;



-- Stored Procedure for booking: [without locking]
-- With locking in "book_with_workshop_id.sql"
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS book(IN wid INT, IN uid INT, IN bdate DATE)
BEGIN
    if(0 < ( select available_slots from slots_availability where workshop_id = wid and date = bdate)) then 
        update slots_availability
        set
        available_slots = available_slots-1
        where
        workshop_id = wid;
        insert into bookings(workshop_id, user_id, booking_date, date_created) values(wid, uid, bdate, now());
       
    else
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'There are no slots available for booking on the given date at the specified workshop.';
    end if;
    select * from bookings;
    select * from slots_availability;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS bTest(IN cid INT)
BEGIN
    DECLARE workshopsInCity IS INTEGER;
    SELECT workshopsInCity := id FROM workshops WHERE city_id=cid;
    SELECT * FROM slots_availability WHERE id in @workshopsInCity;
END $$
DELIMITER ;


-- *****************************************************

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS bTest(IN cid INT)
BEGIN
    DECLARE workshopsInCity IS INTEGER;
    SELECT id INTO workshopsInCity FROM workshops WHERE city_id = cid;
END $$
DELIMITER ;

-- ************************************************
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS bTest(IN cid INT)
BEGIN
    DECLARE workshopsInCity IS VARCHAR(1000);
    DECLARE query IS VARCHAR(500);

    SELECT GROUP_CONCAT(id) INTO workshopsInCity FROM workshops WHERE city_id = cid;
    SET query = CONCAT('SELECT * FROM slots_availability WHERE id IN (', workshopsInCity, ')');
    PREPARE stmt FROM query;
    EXECUTE stmt;
END $$
DELIMITER ;


-- ************************************************
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS bTest(IN cid INT)
BEGIN

    CURSOR workshopsInCity
    SELECT id FROM workshops WHERE city_id = cid;

    SELECT * FROM slots_availability where id in workshopsInCity;
END $$
DELIMITER ;


-- ******************************* Subquery  ******************************
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS bTest(IN cid INT)
BEGIN
    SELECT * FROM slots_availability where workshop_id in (
        SELECT id from workshops where city_id = cid
    );
END $$
DELIMITER ;





-- *******************************NESTED ARRAY ******************************











-- ******************************* CURSOR ******************************
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS bTest(IN cid INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE workshop_id INT;
    
    -- declare the cursor for the workshops in the city
    DECLARE workshopsInCity CURSOR FOR SELECT id FROM workshops WHERE city_id = cid;
    
    -- declare a handler to deal with any errors that may occur
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- open the cursor
    OPEN workshopsInCity;
    
    -- loop through the workshops in the city and fetch their corresponding slots_availability records
    my_loop: LOOP
        -- fetch the next workshop id from the cursor
        FETCH workshopsInCity INTO workshop_id;
        IF done THEN
            -- exit the loop if there are no more workshops in the city
            LEAVE my_loop;
        END IF;
        
        -- select the slots_availability records for the current workshop id
        SELECT * FROM slots_availability WHERE id = workshop_id;
    END LOOP;
    
    -- close the cursor
    CLOSE workshopsInCity;
END $$
DELIMITER ;



SET workshop_ids = (SELECT * FROM slots_availability where workshop_id in (
        SELECT id from workshops where city_id = cid
    ));





-- ******************************* TEst ******************************
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS test1(IN cid INT)
BEGIN
    DECLARE workshop_ids INTARRAY;
    
    SET workshop_ids = (SELECT * FROM slots_availability where workshop_id in (
        SELECT id from workshops where city_id = cid
    ));
    
    SELECT * FROM  workshop_ids;
END $$
DELIMITER ;





-- ******************************* TEMP TABLE ******************************
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS test2(IN cid INT)
BEGIN

    CREATE TEMPORARY TABLE same_city_workshops SELECT * FROM slots_availability where workshop_id in (
        SELECT id from workshops where city_id = cid
    );
    
    SELECT * FROM  same_city_workshops;


END $$
DELIMITER ;





-- *******************************  ******************************
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS test1(IN cid INT)
BEGIN
    



END $$
DELIMITER ;
