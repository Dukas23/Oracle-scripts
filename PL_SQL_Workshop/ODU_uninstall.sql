rem Name
rem  ODU_uninstall.sql
rem
rem Description
rem  This script removes the ODU (Oracle Demo User) schema.
rem
rem Uninstall Instructions
rem  If you have installed the ODU sample schema, you can remove it by
rem  running the ODU_uninstall.sql script
rem
rem Notes
rem  Run as privileged user with rights to create another user (SYSTEM,
rem  ADMIN, etc.)
rem 
rem --------------------------------------------------------------------------

set echo off

-- Exit setup script on any error
whenever sqlerror exit sql.sqlcode

rem =======================================================
rem cleanup ODU schema, if found
rem Use PL/SQL to avoid "user does not exist" error
rem =======================================================

set serveroutput on;
DECLARE
   user_does_not_exist EXCEPTION;
   pragma exception_init(user_does_not_exist, -1918);
BEGIN
    EXECUTE IMMEDIATE 'DROP USER ODU CASCADE';
    -- The next line will only be reached if the ODU schema already exists.
    -- Otherwise the statement above will trigger an exception.
    dbms_output.put_line('ODU schema has been dropped.');
EXCEPTION
   WHEN user_does_not_exist THEN
      -- Ignore error as the user to be dropped does not exist anyway
      dbms_output.put_line('ODU schema does not exist, no actions performed.');
END;
/
set serveroutput off;

-- End of script
DISCONNECT
