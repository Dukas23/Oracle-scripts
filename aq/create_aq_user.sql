SET SERVEROUTPUT ON

DECLARE
  exist NUMBER(1);
BEGIN
    SELECT Count(username)
    INTO   exist
    FROM   dba_users
    WHERE  Lower(username) = 'aq_user';
    
    IF (exist = 1) THEN
      DBMS_OUTPUT.put_line('DROP USER aq_user CASCADE;');
      EXECUTE IMMEDIATE 'DROP USER aq_user CASCADE';
    END IF;
END;
/

CREATE USER aq_user IDENTIFIED BY aq_user DEFAULT
TABLESPACE users
TEMPORARY TABLESPACE temp;

GRANT aq_user_role TO aq_user;
GRANT connect TO aq_user;
