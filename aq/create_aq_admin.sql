SET SERVEROUTPUT ON

DECLARE
  exist NUMBER(1);
BEGIN
    SELECT Count(username)
    INTO   exist
    FROM   dba_users
    WHERE  Lower(username) = 'aq_admin';
    
    IF (exist = 1) THEN
      DBMS_OUTPUT.put_line('DROP USER aq_admin CASCADE;');
      EXECUTE IMMEDIATE 'DROP USER aq_admin CASCADE';
    END IF;
END;
/

CREATE USER aq_admin IDENTIFIED BY aq_admin
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp;

ALTER USER aq_admin QUOTA UNLIMITED ON users;

GRANT aq_administrator_role TO aq_admin;
GRANT connect TO aq_admin;
GRANT create type TO aq_admin;
GRANT create procedure TO aq_admin;
