CREATE DEFINER=`root`@`localhost` PROCEDURE `available_slots_in_workshop`(IN wid int, IN bdate DATE)
BEGIN
	SELECT available_slots from slots_availability where workshop_id = wid AND date = bdate;
END