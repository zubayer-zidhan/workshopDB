-- Using stored procedure book_with_workshop_id
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS book_with_city_id2(IN cid INT, IN uid INT, IN bdate DATE)
BEGIN
    -- Declarations
    DECLARE wid INT;
    DECLARE num_zeros INT;
    DECLARE total_rows INT;

    -- Start the transaction 
    START TRANSACTION;

    -- Find workshops in a city
    DROP TABLE IF EXISTS same_city_workshops;
    CREATE TEMPORARY TABLE same_city_workshops SELECT * FROM slots_availability where workshop_id in (
        SELECT id from workshops where city_id = cid
    );

    -- Count total number of workshops with zero slots 
    select count(*) into num_zeros from same_city_workshops where available_slots = 0;

    -- Count total number of workshops with a given city_id
    select count(*) into total_rows from same_city_workshops;


    -- If there are workshops with more than zero slots left, insert into booking
    if (num_zeros != total_rows) then
        -- Select 1 wid from same_city_workshops
        select workshop_id into wid from same_city_workshops where available_slots <> 0 and date = bdate limit 0, 1;

        -- Call book with wid
        call book_with_workshop_id(wid, uid, bdate); 

        -- Commit the changes to the slots_availability table
        COMMIT;

    else
        -- Error encountered, rollback, release locks
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'There are no slots available for booking on the given date in your city.';
    end if;


END $$
DELIMITER ;
