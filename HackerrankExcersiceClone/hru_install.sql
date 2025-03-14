rem NAME
rem     clone_excercise_hackerrank_install.sql
rem
rem DRESCRIPTION
rem     Clone execersise is an activity proposed in class
rem
rem SHEMA DEPENDENCIES AND REQUIREMENTS
rem     This script calls create_tables.sql, populate_tables.sql
rem
rem INSTALL INSTRUCTIONS
rem 1. Run as privileged user with rights to create another user(sys or admin).
rem 2. Run this script to create the HKU(HACKERRANK USER) schema.
rem 3. You are prompted for
rem     a. Password -enter an Oracle Database compilant password

SET ECHO OFF
SET VERIFY OFF
SET HEADING OFF
SET FEEDBACK OFF

rem =======================================================
rem Accept and verify schema password
rem =======================================================

ACCEPT pass PROMPT 'Enter a password for the user HRU: ' HIDE

BEGIN
   IF '&pass' IS NULL THEN
      RAISE_APPLICATION_ERROR(-20999, 'Error: the HR password is mandatory! Please specify a password!');
   END IF;
END;
/

rem =======================================================
rem Create user
rem =======================================================

CREATE USER HRU IDENTIFIED BY "&pass";

ALTER USER HRU QUOTA UNLIMITED ON USERS;

GRANT CREATE MATERIALIZED VIEW,
      CREATE PROCEDURE,
      CREATE SEQUENCE,
      CREATE SESSION,
      CREATE SYNONYM,
      CREATE TABLE,
      CREATE TRIGGER,
      CREATE TYPE,
      CREATE VIEW
  TO HRU;

ALTER SESSION SET CURRENT_SCHEMA=HRU;

rem =======================================================
rem create HR schema objects
rem =======================================================

@@create_tables.sql

rem =======================================================
rem populate tables with data
rem =======================================================

@@populate_tables.sql


rem =======================================================
rem Query to pass excersise
rem =======================================================

SELECT ROUND(AVG(population)) from CITY;

rem =======================================================
rem Step 6: Change to admin user and delete user
rem =======================================================

ALTER SESSION SET CURRENT_SCHEMA = SYS;

rem =======================================================
rem Cleanup HRU
rem =======================================================

@@hru_unistall.sql

rem End script
EXIT