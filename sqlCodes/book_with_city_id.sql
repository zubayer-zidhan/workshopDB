DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS book_with_city_id(IN cid INT, IN uid INT, IN bdate DATE)
BEGIN
    -- Declarations
    -- DECLARE num_slots INT;
    -- DECLARE workshopsInCity IS VARRAY() OF INTEGER;
    -- TYPE workshopsInCity IS TABLE OF INTEGER [NOT NULL];
    -- DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

    -- Starting the transaction
    -- START TRANSACTION;

    -- Find workshops in a city
    SELECT * FROM slots_availability where workshop_id in (
        SELECT id from workshops where city_id = cid
    );


    -- Find slots in one of the workshops





    -- If no slots, then ROLLBACK
    
END $$
DELIMITER ;
