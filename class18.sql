-- #1
DELIMITER //

CREATE FUNCTION GetFilmCopiesInStore(filmIdentifier INT, storeId INT) RETURNS INT
BEGIN
    DECLARE copies INT;

    IF filmIdentifier < 1000 THEN
        SELECT COUNT(*) INTO copies
        FROM inventory i
        WHERE i.store_id = storeId
        AND i.film_id = filmIdentifier;
    ELSE
        SELECT COUNT(*) INTO copies
        FROM inventory i
        JOIN film f ON i.film_id = f.film_id
        WHERE i.store_id = storeId
        AND f.title = filmIdentifier;
    END IF;

    RETURN copies;
END //

DELIMITER ;
SELECT GetFilmCopiesInStore('3', 2);

-- #2
DELIMITER //

CREATE PROCEDURE RetrieveCustomerListInCountry(
    IN countryName VARCHAR(50),
    OUT customerNames VARCHAR(255)
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE firstName VARCHAR(50);
    DECLARE lastName VARCHAR(50);
    DECLARE fullName VARCHAR(100);

    DECLARE customerCursor CURSOR FOR
        SELECT first_name, last_name
        FROM customer cu
        JOIN address ad ON cu.address_id = ad.address_id
        JOIN city ci ON ad.city_id = ci.city_id
        JOIN country co ON ci.country_id = co.country_id
        WHERE co.country = countryName;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    SET customerNames = '';

    OPEN customerCursor;

    readLoop: LOOP
        FETCH customerCursor INTO firstName, lastName;

        IF done THEN
            LEAVE readLoop;
        END IF;

        SET fullName = CONCAT(firstName, ' ', lastName);

        IF customerNames = '' THEN
            SET customerNames = fullName;
        ELSE
            SET customerNames = CONCAT(customerNames, '; ', fullName);
        END IF;
    END LOOP;

    CLOSE customerCursor;
END;
//
DELIMITER ;

SET @outputCustomerList = '';

CALL RetrieveCustomerListInCountry('Argentina', @outputCustomerList);

SELECT @outputCustomerList;

-- #3

CREATE FUNCTION `inventory_in_stock`(p_inventory_id INT) RETURNS tinyint(1)
BEGIN
    DECLARE v_rentals INT;
    DECLARE v_out INT;

    SELECT COUNT(*) INTO v_rentals
    FROM rental
    WHERE inventory_id = p_inventory_id;

    IF v_rentals = 0 THEN
      RETURN TRUE;
    END IF;

    SELECT COUNT(rental_id) INTO v_out
    FROM inventory LEFT JOIN rental USING(inventory_id)
    WHERE inventory.inventory_id = p_inventory_id
    AND rental.return_date IS NULL;

    IF v_out > 0 THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
END;

CREATE PROCEDURE `film_in_stock`(IN p_film_id INT, IN p_store_id INT, OUT p_film_count INT)
BEGIN
    SELECT inventory_id
    FROM inventory
    WHERE film_id = p_film_id
    AND store_id = p_store_id
    AND inventory_in_stock(inventory_id);

    SELECT COUNT(*)
    FROM inventory
    WHERE film_id = p_film_id
    AND store_id = p_store_id
    AND inventory_in_stock(inventory_id)
    INTO p_film_count;
END;

CALL film_in_stock(1, 3, @total);

SELECT @total;
