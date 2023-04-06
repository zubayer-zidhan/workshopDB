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
-- With locking in "lockin1.sql"
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
