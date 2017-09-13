DELETE FROM Supplier_Ingredient WHERE supplier_id = 4;
UPDATE Supplier SET address = '12345 Musterstad_t, Musterstraße 2' WHERE supplier_id = 4;
DELETE FROM Supplier WHERE supplier_id = 4;

#UPDATE IngredientSearch SET ingredient = 'Gruken' WHERE ingredient = 'Gurken';

SELECT calcCurrency(0.5,'EUR','USD') FROM DUAL;
SELECT compareOffers(1,2) FROM DUAL;

DROP PROCEDURE IF EXISTS test;
DELIMITER //
CREATE PROCEDURE test()
BEGIN
  DECLARE res VARCHAR(120);
  CALL trafficLightRating(1, res);
  SELECT res;
  SELECT 'Hello World!';
END;
//
DELIMITER ;
CALL test();