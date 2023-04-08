DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS book_with_city_id(IN cid INT, IN uid INT, IN bdate DATE)
BEGIN
    -- Declarations
    DECLARE wid INT;
    DECLARE available_slots INT;
    DECLARE num_zeros INT;
    DECLARE total_rows INT;


    -- DECLARE workshopsInCity IS VARRAY() OF INTEGER;
    -- TYPE workshopsInCity IS TABLE OF INTEGER [NOT NULL];
    -- DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

    -- Starting the transaction
    -- START TRANSACTION;

    -- Find workshops in a city
    DROP table same_city_workshops;
    CREATE TEMPORARY TABLE same_city_workshops SELECT * FROM slots_availability where workshop_id in (
        SELECT id from workshops where city_id = cid
    );

    select count(*) into num_zeros from same_city_workshops where available_slots = 0;
    select count(*) into total_rows from same_city_workshops;


    if (num_zeros != total_rows) then
        select workshop_id into wid from same_city_workshops where date = bdate limit 0, 1;
        -- select workshop_id from same_city_workshops where date = bdate limit 0, 1;
        
        
        -- update slots_availability
        -- set available_slots = available_slots-1
        -- where workshop_id = wid and date = bdate;

        select * from slots_availability
        where workshop_id = wid and date = bdate;


        -- insert into bookings(workshop_id, user_id, booking_date, date_created) values(wid, uid, bdate, now());

    end if;

    

    -- Find slots in one of the workshops
    



    -- If no slots, then ROLLBACK
    
END $$
DELIMITER ;


-- DECLARE @MyCursor CURSOR;
    -- BEGIN
    --     SET @MyCursor = CURSOR FOR same_city_workshops.workshop_id

    --     OPEN @MyCursor 
    --     FETCH NEXT FROM @MyCursor 
    --     INTO wid

    --     WHILE @@FETCH_STATUS = 0
    --     BEGIN
    --     /*
    --         YOUR ALGORITHM GOES HERE   
    --     */
    --     FETCH NEXT FROM @MyCursor 
    --     INTO @MyField 
    --     END; 

    --     CLOSE @MyCursor ;
    --     DEALLOCATE @MyCursor;
    -- END;


    

    -- -- for workshop in workshops_ids 
    --     select available_slots into num_slots
    --     from slots_availability
    --     where workshop_id = wid and date = bdate
    --     for update;
    
    --     -- if slots are available, then book   
    --     if(num_slots > 0) then 
    --         update slots_availability
    --         set available_slots = available_slots - 1
    --         where workshop_id = wid and date = bdate;

    --         -- Commit the changes to the database, release the exclusive lock on slots_availability
    --         COMMIT;

    --         -- Insert into bookings table doesn't require exclusive lock
    --         insert into bookings(workshop_id, user_id, booking_date, date_created) values(wid, uid, bdate, now());
        
    --     else
    --         --  move to next wid  
    --     end if;