DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS clearingUp()
BEGIN
    truncate bookings;
    call updateSlots();
END $$
DELIMITER ;