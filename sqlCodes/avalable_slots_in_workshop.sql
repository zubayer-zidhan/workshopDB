CREATE DEFINER=`root`@`localhost` PROCEDURE `available_slots_in_city`(IN cid int, IN bdate DATE)
BEGIN
	SELECT SUM(available_slots) FROM slots_availability WHERE date = bdate AND workshop_id IN (
        SELECT id FROM workshops WHERE city_id = cid
	);
END