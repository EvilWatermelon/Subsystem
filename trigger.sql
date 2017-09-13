CLEAR SCREEN;

CREATE OR REPLACE TRIGGER No_Empty_Supplier
AFTER DELETE ON Supplier_Ingredient
DECLARE 
  suppliers NUMBER;
  mappedSuppliers NUMBER;
BEGIN
  SELECT COUNT(DISTINCT supplier_id) INTO suppliers FROM Supplier;
  SELECT COUNT(DISTINCT supplier_id) INTO mappedSuppliers FROM Supplier_Ingredient;
  IF suppliers != mappedSuppliers THEN
    RAISE_APPLICATION_ERROR (-20001,'Every supplier must sell at least one ingredient');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER Address_Check 
BEFORE INSERT OR UPDATE ON Supplier
FOR EACH ROW
BEGIN
  IF NOT REGEXP_LIKE(:NEW.address, '\d{5} [a-z????]+, [a-z????]+ \d+[a-z]?', 'i') THEN
    RAISE_APPLICATION_ERROR (-20001,'Invalid address');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER No_Supplier_Delete 
BEFORE DELETE ON Supplier
BEGIN
  RAISE_APPLICATION_ERROR (-20002,'Supplier deletion not allowed');
END;
/

CREATE OR REPLACE TRIGGER View_Update 
INSTEAD OF INSERT OR UPDATE OR DELETE ON INGREDIENTSEARCHINSTEADOF
FOR EACH ROW
DECLARE
  ingredientExists NUMBER;
  categoryExists NUMBER;
  categoryId NUMBER;
  ingredientId NUMBER;
BEGIN
  SELECT COUNT(*) INTO ingredientExists FROM Ingredient WHERE ingredient_id = :NEW.ingredient_id;
  SELECT COUNT(*) INTO categoryExists FROM IngredientCategory WHERE category_id = :NEW.category_id;
  
  IF INSERTING OR UPDATING THEN
    IF categoryExists=0 THEN
      INSERT INTO IngredientCategory VALUES(IC_PK_Seq.NEXTVAL,:NEW.category);
      categoryId := IC_PK_Seq.CURRVAL;
    ELSE
      categoryId := :NEW.category_id;
    END IF;
    IF ingredientExists=0 THEN
      INSERT INTO Ingredient VALUES(I_PK_Seq.NEXTVAL,categoryId,:NEW.ingredient,'kg');
      ingredientId := I_PK_Seq.CURRVAL;
    ELSE
      ingredientId := :NEW.ingredient_id;
    END IF;
    
    IF UPDATING THEN
        UPDATE Ingredient SET name = :NEW.ingredient WHERE ingredient_id = ingredientId;
        UPDATE IngredientCategory SET name = :NEW.category WHERE category_id = categoryId;
    END IF;
    
  END IF;
  IF DELETING THEN
    IF ingredientExists!=0 THEN
      DELETE FROM Ingredient WHERE ingredient_id = :OLD.ingredient_id;
    END IF;
  END IF;
END;
/

CREATE OR REPLACE FUNCTION calcCurrency(val IN NUMBER, oldCurrency IN VARCHAR2, newCurrency IN VARCHAR2) RETURN NUMBER AS
BEGIN
  CASE oldCurrency||'-'||newCurrency
    WHEN 'EUR-USD' THEN RETURN val*1.1283;
    WHEN 'USD-EUR' THEN RETURN val*0.8863;
    ELSE RETURN -1;
  END CASE;
END calcCurrency;
/

CREATE OR REPLACE FUNCTION compareOffers(offer1 IN NUMBER, offer2 IN NUMBER) RETURN NUMBER AS
  pricePerKg1 NUMBER;
  pricePerKg2 NUMBER;
BEGIN
   SELECT price/quantity INTO pricePerKg1 FROM Offer WHERE offer_id = offer1;
   SELECT price/quantity INTO pricePerKg2 FROM Offer WHERE offer_id = offer2;
   
   IF pricePerKg1 < pricePerKg2 THEN
    RETURN offer1;
   ELSE
    RETURN offer2;
   END IF;
END compareOffers;
/

CREATE OR REPLACE PROCEDURE trafficLightRating(supplierIn IN NUMBER, rating OUT VARCHAR2) AS
  managerRating NUMBER;
  offerRating NUMBER;
  maxOffers NUMBER;
BEGIN
   BEGIN
    SELECT AVG(Rating.rating) INTO managerRating FROM Rating WHERE supplier_id = supplierIn;
    managerRating := NVL(1,managerRating);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN managerRating := 1;
   END;
   BEGIN
    SELECT MAX(COUNT(supplier_id)) INTO maxOffers FROM Offer NATURAL JOIN Supplier WHERE accepted != 0 GROUP BY supplier_id;
    maxOffers := NVL(1,maxOffers);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN maxOffers := 1;
   END;
   BEGIN
    SELECT COUNT(supplier_id) INTO offerRating FROM Offer NATURAL JOIN Supplier WHERE supplier_id = supplierIn AND accepted != 0 GROUP BY supplier_id;
    offerRating := NVL(0,offerRating);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN offerRating := 0;
   END;
    
   offerRating := offerRating/maxOffers;
   offerRating := ((offerRating*(managerRating-1))/4)*2;
   offerRating := ROUND(offerRating,0);
   
   CASE offerRating
    WHEN 0 THEN rating := 'RED';
    WHEN 1 THEN rating := 'YELLOW';
    WHEN 2 THEN rating := 'GREEN';
    ELSE rating := 'Error';
   END CASE;
END;
/