rem SCHEMA DEPENDENCIES AND REQUIREMENTS
rem   This script is called from the hru_install.sql script
rem 
rem INSTALL INSTRUCTIONS
rem    Run the hru_install.sql script to call this script

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET ECHO OFF 


rem =======================================================
rem Created sequence for table city
rem =======================================================

CREATE SEQUENCE seq_city_id
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

rem =======================================================
rem CREATE table city
rem =======================================================
CREATE TABLE CITY (
    ID NUMBER,
    NAME VARCHAR2(17),
    COUNTRYCODE VARCHAR2(3),
    DISTRICT VARCHAR2(20),
    POPULATION NUMBER
);

rem =======================================================
rem Add trigger for autoincrement ID IN CITY
rem =======================================================
CREATE OR REPLACE TRIGGER trg_city_id_increment
BEFORE INSERT ON CITY
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT seq_city_id.NEXTVAL INTO :NEW.ID FROM dual;
    END IF;
END;
/