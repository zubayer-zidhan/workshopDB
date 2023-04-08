DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS book_with_city_id(IN cid INT, IN uid INT, IN bdate DATE)
BEGIN
    -- Declarations
    DECLARE wid INT;
    DECLARE num_zeros INT;
    DECLARE total_rows INT;

    -- Find workshops in a city
    DROP TABLE IF EXISTS same_city_workshops;


    -- TODO: Need to lock the temp table ???
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


        -- TODO: Get lock on slots_availability table
        update slots_availability
        set available_slots = available_slots - 1
        where workshop_id = wid and date = bdate;

        -- TODO: Release locks

        insert into bookings(workshop_id, user_id, booking_date, date_created) values(wid, uid, bdate, now());

    -- TODO: If no slots, then ROLLBACK


    
    end if;


    
END $$
DELIMITER ;
