SET ECHO OFF

-- Exit setup script on any error
WHENEVER SQLERROR EXIT SQL.SQLCODE

REM =======================================================
REM cleanup HRU schema, if found
REM Use PL/SQL to avoid "user does not exist" error
REM =======================================================

SET SERVEROUTPUT ON;
DECLARE
   user_does_not_exist EXCEPTION;
   pragma exception_init(user_does_not_exist, -1918);
BEGIN
   EXECUTE IMMEDIATE 'DROP USER HRU CASCADE';
--    EXECUTE IMMEDIATE 'DROP TABLE CITY CASCADE';
   -- The next line will only be reached if the HR schema already exists.
   -- Otherwise the statement above will trigger an exception.
   DBMS_OUTPUT.PUT_LINE('HRU schema has been dropped.');
EXCEPTION
   WHEN user_does_not_exist THEN
      -- Ignore error as the user to be dropped does not exist anyway
      DBMS_OUTPUT.PUT_LINE('HRU schema does not exist, no actions performed.');
END;
/
SET SERVEROUTPUT OFF;

--
-- Disconnect again from database to prevent any accidental commands being
-- executed as a privileged user.
-- Use 'disconnect' instead of 'exit' to leave SQL*Plus Window open on Windows.
--
disconnect
