DROP TRIGGER IF EXISTS No_Empty_Supplier;
DROP TRIGGER IF EXISTS Address_Check;
DROP TRIGGER IF EXISTS No_Supplier_Delete;
DROP FUNCTION IF EXISTS calcCurrency;
DROP FUNCTION IF EXISTS compareOffers;
DROP PROCEDURE IF EXISTS trafficLightRating;

DELIMITER //

/*CREATE TRIGGER No_Empty_Supplier
AFTER DELETE ON Supplier_Ingredient
FOR EACH ROW
BEGIN
  DECLARE suppliers INT;
  DECLARE mappedSuppliers INT;
  SELECT COUNT(DISTINCT supplier_id) INTO suppliers FROM Supplier;
  SELECT COUNT(DISTINCT supplier_id) INTO mappedSuppliers FROM Supplier_Ingredient;
  IF suppliers != mappedSuppliers THEN
     SIGNAL SQLSTATE '-20001' SET MESSAGE_TEXT = 'Every supplier must sell at least one ingredient';
  END IF;
END;
//*/

CREATE TRIGGER Address_Check 
BEFORE INSERT ON Supplier
FOR EACH ROW
BEGIN
  IF NOT REGEXP_LIKE(NEW.address, '\d{5} [a-zäöüß]+, [a-zäöüß]+ \d+[a-z]?', 'i') THEN
    SIGNAL SQLSTATE '-20001' SET MESSAGE_TEXT = 'Invalid address';
  END IF;
END;
//
CREATE TRIGGER Address_Check 
BEFORE UPDATE ON Supplier
FOR EACH ROW
BEGIN
  IF NOT REGEXP_LIKE(NEW.address, '\d{5} [a-zäöüß]+, [a-zäöüß]+ \d+[a-z]?', 'i') THEN
    SIGNAL SQLSTATE '-20001' SET MESSAGE_TEXT = 'Invalid address';
  END IF;
END;
//

CREATE TRIGGER No_Supplier_Delete 
BEFORE DELETE ON Supplier
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '-20001' SET MESSAGE_TEXT = 'Supplier deletion not allowed';
END;
//

CREATE FUNCTION calcCurrency(val INT, oldCurrency VARCHAR(3), newCurrency VARCHAR(3)) RETURNS INT
BEGIN
  CASE oldCurrency||'-'||newCurrency
    WHEN 'EUR-USD' THEN RETURN val*1.1283;
    WHEN 'USD-EUR' THEN RETURN val*0.8863;
    ELSE RETURN -1;
  END CASE;
END;
//

CREATE FUNCTION compareOffers(offer1 INT, offer2 INT) RETURNS INT
BEGIN
   DECLARE pricePerKg1 INT;
   DECLARE pricePerKg2 INT;
   SELECT price/quantity INTO pricePerKg1 FROM Offer WHERE offer_id = offer1;
   SELECT price/quantity INTO pricePerKg2 FROM Offer WHERE offer_id = offer2;
   
   IF pricePerKg1 < pricePerKg2 THEN
    RETURN offer1;
   ELSE
    RETURN offer2;
   END IF;
END;
//

CREATE PROCEDURE trafficLightRating(IN supplier INT, OUT rating VARCHAR(6))
BEGIN
   DECLARE managerRating INT;
   DECLARE offerRating INT;
   DECLARE maxOffers INT;
   BEGIN
	 DECLARE CONTINUE HANDLER FOR NOT FOUND SET managerRating = 1;
     SELECT AVG(Rating.rating) INTO managerRating FROM Rating WHERE supplier_id = supplier;
	 managerRating := COALESCE(1,managerRating);
   END;
   BEGIN
	 DECLARE CONTINUE HANDLER FOR NOT FOUND SET offerRating = 0;
     SELECT MAX(COUNT(supplier_id)) INTO maxOffers FROM Offer NATURAL JOIN Supplier WHERE accepted != 0 GROUP BY supplier_id;
	 maxOffers := COALESCE(1,maxOffers);
   END;
   BEGIN
	 DECLARE CONTINUE HANDLER FOR NOT FOUND SET offerRating = 0;
     SELECT COUNT(supplier_id) INTO offerRating FROM Offer NATURAL JOIN Supplier WHERE supplier_id = supplier AND accepted != 0 GROUP BY supplier_id;
	 offerRating := COALESCE(0,offerRating);
   END;
   
   SET offerRating = offerRating/maxOffers;
   SET offerRating = ((offerRating*(managerRating-1))/4)*2;
   SET offerRating = ROUND(offerRating,0);
   
   CASE offerRating
    WHEN 0 THEN SET rating = 'RED';
    WHEN 1 THEN SET rating = 'YELLOW';
    WHEN 2 THEN SET rating = 'GREEN';
    ELSE SET rating = 'Error';
   END CASE;
END;
//

DELIMITER ;