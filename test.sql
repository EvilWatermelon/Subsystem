CLEAR SCREEN;
DELETE FROM Supplier_Ingredient WHERE supplier_id = 4;
UPDATE Supplier SET address = '12345 Musterstad_t, Musterstraﬂe 2' WHERE supplier_id = 4;
DELETE FROM Supplier WHERE supplier_id = 4;

UPDATE IngredientSearchInsteadOf SET ingredient = 'Gruken' WHERE ingredient = 'Gurken';

SELECT calcCurrency(0.5,'EUR','USD') FROM DUAL;
SELECT compareOffers(1,2) FROM DUAL;
SET SERVEROUTPUT ON;
DECLARE
  res VARCHAR2(120);
BEGIN
  trafficLightRating(3, res);
  dbms_output.put_line(res);
END;
/