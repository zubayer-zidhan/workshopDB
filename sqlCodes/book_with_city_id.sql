DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS book_with_city_id(IN cid INT, IN uid INT, IN bdate DATE)
BEGIN
    -- Declarations
    DECLARE workshop_ids INT;
    DECLARE available_slots INT;


    -- DECLARE workshopsInCity IS VARRAY() OF INTEGER;
    -- TYPE workshopsInCity IS TABLE OF INTEGER [NOT NULL];
    -- DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

    -- Starting the transaction
    -- START TRANSACTION;

    -- Find workshops in a city
    SET workshop_ids = (SELECT * FROM slots_availability where workshop_id in (
        SELECT id from workshops where city_id = cid
    ));


    -- for workshop in workshops_ids 
        select available_slots into num_slots
        from slots_availability
        where workshop_id = wid and date = bdate
        for update;
    

        -- if slots are available, then book   
        if(num_slots > 0) then 
            update slots_availability
            set available_slots = available_slots - 1
            where workshop_id = wid and date = bdate;

            -- Commit the changes to the database, release the exclusive lock on slots_availability
            COMMIT;

            -- Insert into bookings table doesn't require exclusive lock
            insert into bookings(workshop_id, user_id, booking_date, date_created) values(wid, uid, bdate, now());
        
        else
            --  move to next wid  
        end if;

    -- Find slots in one of the workshops
    



    -- If no slots, then ROLLBACK
    
END $$
DELIMITER ;
