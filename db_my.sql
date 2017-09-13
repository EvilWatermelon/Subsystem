DROP TABLE Offer;
DROP TABLE Supplier_Ingredient;
DROP TABLE Ingredient;
DROP TABLE IngredientCategory;
DROP TABLE Rating;
DROP TABLE Manager;
DROP TABLE Supplier;

CREATE TABLE Ingredient
(
	ingredient_id        INT NOT NULL AUTO_INCREMENT,
	category_id          INT NOT NULL,
	name                 VARCHAR(120) NOT NULL UNIQUE
	unit				 VARCHAR(120) NOT NULL CHECK(unit IN ('kg','items','g','ml','l'))
);
CREATE UNIQUE INDEX XPKIngredient ON Ingredient(ingredient_id ASC);
ALTER TABLE Ingredient ADD CONSTRAINT  XPKIngredient PRIMARY KEY(ingredient_id);

CREATE TABLE IngredientCategory
(
	category_id          INT NOT NULL AUTO_INCREMENT,
	name                 VARCHAR(120) NOT NULL UNIQUE
);
CREATE UNIQUE INDEX XPKIngredientCategory ON IngredientCategory(category_id ASC);
ALTER TABLE IngredientCategory ADD CONSTRAINT  XPKIngredientCategory PRIMARY KEY(category_id);

CREATE TABLE Manager
(
	manager_id           INT NOT NULL AUTO_INCREMENT,
	name                 VARCHAR(120) NOT NULL,
	hash                 VARCHAR(64) NOT NULL,
	salt                 VARCHAR(20) NOT NULL UNIQUE,
	username             VARCHAR(20) NOT NULL UNIQUE,
    sex                  VARCHAR(1) NOT NULL CHECK(sex IN ('m','w'))
);
CREATE UNIQUE INDEX XPKManager ON Manager(manager_id ASC);

ALTER TABLE Manager ADD CONSTRAINT  XPKManager PRIMARY KEY(manager_id);

CREATE TABLE Supplier
(
	supplier_id          INT NOT NULL AUTO_INCREMENT,
	company				 VARCHAR(120) NOT NULL UNIQUE,
	name                 VARCHAR(120) NOT NULL,
	email                VARCHAR(120) NOT NULL,
	phone				 VARCHAR(120) NOT NULL,
	status               VARCHAR(10) DEFAULT 'ACTIVE' NOT NULL CHECK(status IN('ACTIVE','INACTIVE')),
	address              VARCHAR(120) NOT NULL 
);
CREATE UNIQUE INDEX XPKSupplier ON Supplier(supplier_id ASC);
ALTER TABLE Supplier ADD CONSTRAINT  XPKSupplier PRIMARY KEY(supplier_id);

CREATE TABLE Offer
(
	supplier_id          INT NOT NULL,
	offer_id             INT NOT NULL AUTO_INCREMENT,
	manager_id           INT NOT NULL,
	ingredient_id        INT NOT NULL,
	datum                DATE NOT NULL,
	price                INT NOT NULL CHECK(price > 0),
	quantity             INT NOT NULL CHECK(quantity>0),
	accepted             SMALLINT DEFAULT 0 NOT NULL  
);
CREATE UNIQUE INDEX XPKOffer ON Offer(offer_id ASC);
ALTER TABLE Offer ADD CONSTRAINT  XPKOffer PRIMARY KEY(offer_id);

CREATE TABLE Supplier_Ingredient
(
	supplier_id          INT NOT NULL,
	ingredient_id        INT NOT NULL 
);
CREATE UNIQUE INDEX XPKSupplier_Ingredient ON Supplier_Ingredient(supplier_id ASC, ingredient_id ASC);
ALTER TABLE Supplier_Ingredient ADD CONSTRAINT  XPKSupplier_Ingredient PRIMARY KEY(supplier_id, ingredient_id);

CREATE TABLE Rating
(
	rating_id            INT NOT NULL AUTO_INCREMENT,
	text                 VARCHAR(120) NULL,
	rating               INT NULL CHECK(rating >= 0 AND rating <= 5),
	supplier_id          INT NOT NULL,
	manager_id           INT NOT NULL 
);
CREATE UNIQUE INDEX XPKRating ON Rating(rating_id ASC);
ALTER TABLE Rating ADD CONSTRAINT  XPKRating PRIMARY KEY(rating_id);

ALTER TABLE Ingredient ADD CONSTRAINT R_1 FOREIGN KEY(category_id) REFERENCES IngredientCategory(category_id) ON DELETE CASCADE;

ALTER TABLE Offer ADD CONSTRAINT R_2 FOREIGN KEY(supplier_id) REFERENCES Supplier(supplier_id);
ALTER TABLE Offer ADD CONSTRAINT R_3 FOREIGN KEY(manager_id) REFERENCES Manager(manager_id);
ALTER TABLE Offer ADD CONSTRAINT R_4 FOREIGN KEY(ingredient_id) REFERENCES Ingredient(ingredient_id);

ALTER TABLE Supplier_Ingredient ADD CONSTRAINT R_5 FOREIGN KEY(supplier_id) REFERENCES Supplier(supplier_id);
ALTER TABLE Supplier_Ingredient ADD CONSTRAINT R_6 FOREIGN KEY(ingredient_id) REFERENCES Ingredient(ingredient_id);

ALTER TABLE Rating ADD CONSTRAINT R_7 FOREIGN KEY(supplier_id) REFERENCES Supplier(supplier_id);
ALTER TABLE Rating ADD CONSTRAINT R_8 FOREIGN KEY(manager_id) REFERENCES Manager(manager_id);



INSERT INTO IngredientCategory VALUES(IC_PK_Seq.NEXTVAL,'Obst');
INSERT INTO Ingredient VALUES(I_PK_Seq.NEXTVAL,IC_PK_Seq.CURRVAL,'Äpfel','kg');
INSERT INTO Ingredient VALUES(I_PK_Seq.NEXTVAL,IC_PK_Seq.CURRVAL,'Birnen','kg');
INSERT INTO Ingredient VALUES(I_PK_Seq.NEXTVAL,IC_PK_Seq.CURRVAL,'Weintrauben','kg');
INSERT INTO IngredientCategory VALUES(IC_PK_Seq.NEXTVAL,'Gemüse');
INSERT INTO Ingredient VALUES(I_PK_Seq.NEXTVAL,IC_PK_Seq.CURRVAL,'Gurken','kg');
INSERT INTO Ingredient VALUES(I_PK_Seq.NEXTVAL,IC_PK_Seq.CURRVAL,'Tomaten','kg');
INSERT INTO Ingredient VALUES(I_PK_Seq.NEXTVAL,IC_PK_Seq.CURRVAL,'Kartoffeln','kg');

INSERT INTO Manager VALUES(M_PK_Seq.NEXTVAL,'Moritz Meter','142842B4C729FAE19DA47DCEBBC739564ADA2D9FBBE401905DDD3B964F2BEFAB','salt','mome','m');

INSERT INTO Supplier VALUES(S_PK_Seq.NEXTVAL,'Meyers Lebensmittel','Michael Myers','mmyers@gmx.de','12345678','ACTIVE','12345 Musterstadt, Musterstraße 2');
INSERT INTO Supplier_Ingredient VALUES(S_PK_Seq.CURRVAL,I_PK_Seq.CURRVAL);
INSERT INTO Rating VALUES(R_PK_Seq.NEXTVAL,'Blabla',4,S_PK_Seq.CURRVAL,M_PK_Seq.CURRVAL);
INSERT INTO Supplier VALUES(S_PK_Seq.NEXTVAL,'Müller Lebensmittel','Max Müller','mmueller@gmx.de','12121212','ACTIVE','13579 Musterort, Musteralle 2');
INSERT INTO Supplier_Ingredient VALUES(S_PK_Seq.CURRVAL,I_PK_Seq.CURRVAL);
INSERT INTO Rating VALUES(R_PK_Seq.NEXTVAL,'Blabla',3,S_PK_Seq.CURRVAL,M_PK_Seq.CURRVAL);
INSERT INTO Supplier VALUES(S_PK_Seq.NEXTVAL,'Muster Lebensmittel','Manuel Muster','mmuster@gmx.de','33333333','ACTIVE','24680 Musterdorf, Musterweg 2');
INSERT INTO Supplier_Ingredient VALUES(S_PK_Seq.CURRVAL,I_PK_Seq.CURRVAL);
INSERT INTO Rating VALUES(R_PK_Seq.NEXTVAL,'Blabla',4,S_PK_Seq.CURRVAL,M_PK_Seq.CURRVAL);

INSERT INTO Offer VALUES(S_PK_Seq.CURRVAL,O_PK_Seq.NEXTVAL,M_PK_Seq.CURRVAL,I_PK_Seq.CURRVAL,SYSDATE,10,10,0);
INSERT INTO Offer VALUES(S_PK_Seq.CURRVAL,O_PK_Seq.NEXTVAL,M_PK_Seq.CURRVAL,I_PK_Seq.CURRVAL,SYSDATE,10,20,0);