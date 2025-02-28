rem NAME
rem airbnb_create.sql - Creates schemas objects for Uceva(unidad central del valle del cauca)
rem for this example
rem
rem 
rem DESCRIPTION
rem This script creates tables, associated constrains and comments in the Uceva shema
rem
rem 

SET FEEDBACK ON 
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET ECHO OFF 

rem ****************************************************************************
rem Create the USERS table

PROMPT ******** Creating USERS table ....

create table users
    (id varchar2(60) NOT NULL
    ,updated_at TIMESTAMP
    ,created_at TIMESTAMP
    ,email varchar2(100)
    ,password varchar2(150)
    ,first_name varchar2(255)
    ,last_name varchar2(255)
    );
    
rem Genereted User id

CREATE OR REPLACE TRIGGER TRG_USER_UUID
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := SYS_GUID();
    END IF;
END;
/

rem ****************************************************************************
rem Create the review table

PROMPT ******** Creating REVIEWS table ....

CREATE TABLE reviews
    (id varchar2(60) NOT NULL
    ,update_at TIMESTAMP
    ,created_at TIMESTAMP
    ,user_id varchar2(60)
    ,place_id varchar2(60)
    ,text VARCHAR2(255)
    );

rem Generated review_id

CREATE OR REPLACE TRIGGER TRG_REVIEW_UUID
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := SYS_GUID();
    END IF;
END;
/
rem ****************************************************************************
rem Create the place table

PROMPT ******** Creating PLACES table ....

create table places
    (id varchar2(60) NOT NULL
    ,updated_at TIMESTAMP
    ,created_at TIMESTAMP
    ,user_id varchar2(60)
    ,name varchar2(60)
    ,city_id varchar2(60)
    ,description varchar2(1024)
    ,number_rooms integer default 0
    ,number_bathrooms integer default 0
    ,max_guest integer default 0
    ,price_by_night integer default 0
    ,latitude float
    ,longitude float
    );

CREATE OR REPLACE TRIGGER TRG_PLACE_UUID
BEFORE INSERT ON places
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := SYS_GUID();
    END IF;
END;
/
grant create trigger to uceva;

rem Create the amenities table

PROMPT ******** Creating amenities table ....

CREATE TABLE amenities
    (id varchar2(60) NOT NULL
    ,update_at TIMESTAMP
    ,create_at TIMESTAMP
    ,name varchar2(150)
    );
    
rem Create trigger

CREATE OR REPLACE TRIGGER TRG_AMENITY_UUID
BEFORE INSERT ON amenities
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := SYS_GUID();
    END IF;
END;
/
rem ****************************************************************************
rem Create table PlaceAmenity

PROMPT ******** Creating placeAmenity table ....

CREATE TABLE placeAmenity 
    (place_id VARCHAR2(60) NOT NULL
    ,amenity_id VARCHAR2(60) NOT NULL    
    );

rem ****************************************************************************
rem Create table State

PROMPT ******** Creating states table ....

CREATE TABLE states
    (id varchar2(60) NOT NULL
    ,update_at TIMESTAMP
    ,create_at TIMESTAMP
    ,name varchar(100)
    );

CREATE OR REPLACE TRIGGER TRG_STATE_UUID
BEFORE INSERT ON states
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := SYS_GUID();
    END IF;
END;
/

rem ****************************************************************************
rem Create table Cities

PROMPT ******** Creating cities table ....

CREATE TABLE cities
    (id varchar2(60) NOT NULL
    ,update_at TIMESTAMP
    ,create_at TIMESTAMP
    ,state_id varchar2(60)
    ,name varchar(100)
    );

CREATE OR REPLACE TRIGGER TRG_CITIES_UUID
BEFORE INSERT ON cities
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := SYS_GUID();
    END IF;
END;
/

rem Adding contraints for created tables
PROMPT ******** Adding PRIMARY KEY constraints ....

-- Primary Key constraints
ALTER TABLE users ADD CONSTRAINT PK_USERS PRIMARY KEY (id);
ALTER TABLE reviews ADD CONSTRAINT PK_REVIEWS PRIMARY KEY (id);
ALTER TABLE places ADD CONSTRAINT PK_PLACES PRIMARY KEY (id);
ALTER TABLE amenities ADD CONSTRAINT PK_AMENITIES PRIMARY KEY (id);
ALTER TABLE states ADD CONSTRAINT PK_STATES PRIMARY KEY (id);
ALTER TABLE cities ADD CONSTRAINT PK_CITIES PRIMARY KEY (id);
ALTER TABLE placeAmenity ADD CONSTRAINT PK_PLACE_AMENITIES PRIMARY KEY (place_id, amenity_id);

PROMPT ******** Adding FOREIGN KEY constraints ....
-- Foreign Key constraints
ALTER TABLE reviews ADD CONSTRAINT FK_REVIEWS_USERS
FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE reviews ADD CONSTRAINT FK_REVIEWS_PLACES
FOREIGN KEY (place_id) REFERENCES places(id);

ALTER TABLE places ADD CONSTRAINT FK_PLACES_USERS
FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE places ADD CONSTRAINT FK_PLACES_CITIES
FOREIGN KEY (city_id) REFERENCES cities(id);

ALTER TABLE cities ADD CONSTRAINT FK_CITIES_STATES
FOREIGN KEY (state_id) REFERENCES states(id);

ALTER TABLE placeAmenity ADD CONSTRAINT FK_PLACE_AMENITIES_PLACES
FOREIGN KEY (place_id) REFERENCES places(id);

ALTER TABLE placeAmenity ADD CONSTRAINT FK_PLACE_AMENITIES_AMENITIES
FOREIGN KEY (amenity_id) REFERENCES amenities(id);


PROMPT ******** Constraints added successfully ....