DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS viewTables()
BEGIN
    select * from bookings;
    select * from workshops order by city_id;
    select * from slots_availability;
END $$
DELIMITER ;