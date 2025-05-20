rem NAME
rem     ODU_install.sql
rem
rem DRESCRIPTION
rem     This script create the ODMU user and grants the necessary privileges to the user.
rem     It also creates the tables and populates them with data.
rem     The script is designed to be run as a privileged user.
rem
rem SHEMA DEPENDENCIES AND REQUIREMENTS
rem     This script calls demobld_new.sql, 
rem
rem INSTALL INSTRUCTIONS
rem 1. Run as privileged user with rights to create another user(sys or admin).
rem 2. Run this script to create the ODU(Oracle Demo User) schema.
rem 3. You are prompted for
rem     a. Password -enter an Oracle Database compilant password

SET ECHO OFF
SET VERIFY OFF
SET HEADING OFF
SET FEEDBACK OFF


-- Exit setup script on any error
WHENEVER SQLERROR EXIT SQL.SQLCODE

rem =======================================================
rem Install descriptions
rem =======================================================

PROMPT
PROMPT Thank you for installing the Oracle Demo User (ODU) Sample Schema.
PROMPT This installation script will automatically exit your database session
PROMPT at the end of the installation or if any error is encountered.
PROMPT The entire installation will be logged into the 'ODU_install.log' log file.
PROMPT
rem =======================================================
rem Chance language settings to English
rem =======================================================

ALTER SESSION SET NLS_DATE_LANGUAGE = 'ENGLISH';

rem =======================================================
rem Log installation process
rem =======================================================

SPOOL ODU_install.log

rem =======================================================
rem Accept and verify schema password
rem =======================================================

ACCEPT pass PROMPT 'Enter a password for the user ODU: ' HIDE

BEGIN
   IF '&pass' IS NULL THEN
      RAISE_APPLICATION_ERROR(-20999, 'Error: the ODU password is mandatory! Please specify a password!');
   END IF;
END;
/

rem =======================================================
rem Cleanup old ODU schema, if found and requested
rem =====================================================

ACCEPT overwrite_schema PROMPT 'Do you want to overwrite the existing ODU schema (Y/N)? ' DEFAULT 'N' HIDE
SET SERVEROUTPUT ON;
DECLARE
    v_user_exists all_users.username%TYPE;
BEGIN
    SELECT MAX(username) INTO v_user_exists
    FROM all_users
    WHERE username = 'ODU';
    -- Schema already exists
    IF v_user_exists is not null THEN
        -- Overwrite schema if the user chose to do so
        IF UPPER('&overwrite_schema') = 'YES' THEN
         EXECUTE IMMEDIATE 'DROP USER ODU CASCADE';
         DBMS_OUTPUT.PUT_LINE('Old ODU schema has been dropped.');
      -- or raise error if the user doesn't want to overwrite it
      ELSE
         RAISE_APPLICATION_ERROR(-20997, 'Abort: the schema already exists and the user chose not to overwrite it.');
      END IF;
   END IF;
END;
/
SET SERVEROUTPUT OFF;

rem =======================================================
rem Create the ODU shecma user
rem =======================================================

CREATE USER ODU IDENTIFIED BY "&pass";

ALTER USER ODU QUOTA UNLIMITED ON USERS;

GRANT CREATE MATERIALIZED VIEW,
      CREATE PROCEDURE,
      CREATE SEQUENCE,
      CREATE SESSION,
      CREATE SYNONYM,
      CREATE TABLE,
      CREATE TRIGGER,
      CREATE TYPE,
      CREATE VIEW
  TO ODU;

ALTER SESSION SET CURRENT_SCHEMA=ODU;

rem =======================================================
rem Create the ODU schema objects and populate them with data
rem =======================================================

@@demobld_new.sql


rem stop writing to the log file

spool off

rem
rem Exit from the session.
rem Use 'exit' and not 'disconnect' to keep behavior the same for when errors occur.
rem
exit