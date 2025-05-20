-- Liquidar los pagos
-- Tenemos los empleados de la empresa cuyos datos están en la tabla “emp” (Empleados), y
-- queremos realizar el pago de la nómina cuyos registros de liquidación se guardan en la
-- tabla “payment” y parten de los salarios y comisiones vigentes.

-- Opción 1:
INSERT INTO PAYMENT (EMPNO, PAYDATE, SAL, COMM)
   SELECT EMPNO, TRUNC(SYSDATE), SAL, COMM
   FROM EMP;

-- opcion 2:
CREATE OR REPLACE PROCEDURE process_payroll IS
   BEGIN
     FOR emp_rec IN (SELECT EMPNO, SAL, COMM FROM EMP) LOOP
       INSERT INTO PAYMENT (EMPNO, PAYDATE, SAL, COMM)
       VALUES (emp_rec.EMPNO, TRUNC(SYSDATE), emp_rec.SAL, emp_rec.COMM);
     END LOOP;
     COMMIT;
   END;
   /
   
   EXECUTE process_payroll;

SELECT * from PAYMENT;

--Liquidar los pagos
-- Tenemos los empleados de la empresa cuyos datos están en la tabla “emp” (Empleados), y
-- queremos realizar el pago de la nómina cuyos registros de liquidación se guardan en la
-- tabla “payment” y parten de los salarios y comisiones vigentes. También se quiere que en la
-- medida en que el salario de empleado se encuentre en el rango 4 o superior se registre este
-- hecho en la bitácora (tabla “log”) con un texto descriptivo.

CREATE OR REPLACE PROCEDURE process_payroll_with_log IS
   BEGIN
     FOR emp_rec IN (SELECT EMPNO, SAL, COMM FROM EMP) LOOP
       INSERT INTO PAYMENT (EMPNO, PAYDATE, SAL, COMM)
       VALUES (emp_rec.EMPNO, TRUNC(SYSDATE), emp_rec.SAL, emp_rec.COMM);
   
       IF emp_rec.SAL >= 3000 THEN 
         INSERT INTO LOGEMP (OCCDATE, MSG)
         VALUES (TRUNC(SYSDATE), 'High salary processed for employee: ' || emp_rec.EMPNO);
       END IF;
     END LOOP;
     COMMIT;
   END;
   /
   
   EXECUTE process_payroll_with_log;

   SELECT * from LOGEMP;

-- Actualizar nombre
-- Tenemos los empleados de la empresa cuyos datos están en la tabla “emp” (Empleados), y
-- queremos actualizar el nombre del empleado permitiendo el suministro del código del
-- empleado a modificar y el nuevo nombre. Los datos deben ser ejecutados en una función de
-- la base de datos que se llame desde un PL/SQL anónimo.

   CREATE OR REPLACE FUNCTION update_employee_name_dynamic(p_empno IN NUMBER, p_ename IN VARCHAR2)
   RETURN VARCHAR2 IS
     v_sql VARCHAR2(200);
   BEGIN
     v_sql := 'UPDATE EMP SET ENAME = ''' || p_ename || ''' WHERE EMPNO = ' || p_empno;
     EXECUTE IMMEDIATE v_sql;
     RETURN 'Employee name updated successfully';
   EXCEPTION
     WHEN OTHERS THEN
       RETURN 'Error updating employee name';
   END;
   /
   
   -- Anonymous PL/SQL block to call the function
   DECLARE
     v_result VARCHAR2(100);
   BEGIN
     v_result := update_employee_name_dynamic(7369, 'JONH');
     DBMS_OUTPUT.PUT_LINE(v_result);
   END;
   /    
-- para verificar el resultado si ejecuto el bloque anterior
   ROLLBACK;

    SELECT * FROM EMP WHERE EMPNO = 7369;

-- Liquidar los pagos
-- Tenemos los empleados de la empresa cuyos datos están en la tabla “emp” (Empleados), y
-- queremos realizar el pago de la nómina cuyos registros de liquidación se guardan en la
-- tabla “payment” y parten de los salarios y comisiones vigentes. También se quiere que en la
-- medida en que el salario de empleado se encuentre en el rango 4 o superior se registre este
-- hecho en la bitácora (tabla “log”) con un texto descriptivo. Se requiere que este proceso
-- quede como un procedimiento almacenado en la base de datos.
CREATE OR REPLACE PROCEDURE process_payroll_stored IS
   BEGIN
     INSERT INTO PAYMENT (EMPNO, PAYDATE, SAL, COMM)
     SELECT EMPNO, TRUNC(SYSDATE), SAL, COMM
     FROM EMP;
     COMMIT;
   END;
   /
   
   EXECUTE process_payroll_stored;

    SELECT * from PAYMENT;

-- Auditoria de cambio de sueldos
-- Tenemos los empleados de la empresa cuyos datos están en la tabla “emp” (Empleados), y
-- queremos trazar en una tabla de auditoría cualquier cambio que se realice en los salarios o
-- comisiones que se definan para devengo.
CREATE OR REPLACE TRIGGER audit_emp_salary_change
   AFTER UPDATE ON EMP
   FOR EACH ROW
   DECLARE
     v_user VARCHAR2(40);
   BEGIN
     SELECT USER INTO v_user FROM DUAL;
     IF :OLD.SAL <> :NEW.SAL OR :OLD.COMM <> :NEW.COMM THEN
       INSERT INTO AUDITEMP (CHANGED_TYPE, CHANGED_BY, DATESTAMP, EMPNO, OLDSAL, OLDCOMM, NEWSAL, NEWCOMM)
       VALUES ('U', v_user, SYSDATE, :OLD.EMPNO, :OLD.SAL, :OLD.COMM, :NEW.SAL, :NEW.COMM);
     END IF;
   END;
   /

   SELECT * FROM AUDITEMP;

-- Paquete de servicios – actualización de salario
-- Se requiere que se tenga un servicio de actualización de sueldos de los empleados de un
-- departamento específico de la empresa, que se suministra. El porcentaje de incremento se
-- suministra y se aplica para todos los rangos excepto para el rango 2 que no tendrá
-- incremento.
CREATE OR REPLACE PACKAGE emp_salary_mgmt AS
     PROCEDURE update_dept_salaries(p_deptno IN NUMBER, p_percent IN NUMBER);
   END emp_salary_mgmt;
   /
   
   CREATE OR REPLACE PACKAGE BODY emp_salary_mgmt AS
     PROCEDURE update_dept_salaries(p_deptno IN NUMBER, p_percent IN NUMBER) IS
     BEGIN
       FOR emp_rec IN (SELECT EMPNO, SAL FROM EMP WHERE DEPTNO = p_deptno) LOOP
         DECLARE
           v_grade NUMBER;
         BEGIN
           SELECT GRADE INTO v_grade FROM SALGRADE
           WHERE emp_rec.SAL BETWEEN LOSAL AND HISAL;
           
           IF v_grade <> 2 THEN
             UPDATE EMP SET SAL = emp_rec.SAL * (1 + p_percent / 100)
             WHERE EMPNO = emp_rec.EMPNO;
           END IF;
         END;
       END LOOP;
       COMMIT;
     END update_dept_salaries;
   END emp_salary_mgmt;
   /
   
   -- Example of execution
   EXECUTE emp_salary_mgmt.update_dept_salaries(10, 5);


--Paquete de servicios – obtener salario actual
-- Se requiere que se tenga un servicio que permita obtener el salario actual de un empleado
-- bien sea que se suministre el código o que se suministre el nombre del mismo.

CREATE OR REPLACE PACKAGE emp_salary_info AS
     FUNCTION get_salary(p_empno IN NUMBER) RETURN NUMBER;
     FUNCTION get_salary(p_ename IN VARCHAR2) RETURN NUMBER;
   END emp_salary_info;
   /
   
   CREATE OR REPLACE PACKAGE BODY emp_salary_info AS
     FUNCTION get_salary(p_empno IN NUMBER) RETURN NUMBER IS
       v_salary NUMBER;
     BEGIN
       SELECT SAL INTO v_salary FROM EMP WHERE EMPNO = p_empno;
       RETURN v_salary;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RETURN NULL;
     END get_salary;
   
     FUNCTION get_salary(p_ename IN VARCHAR2) RETURN NUMBER IS
       v_salary NUMBER;
     BEGIN
       SELECT SAL INTO v_salary FROM EMP WHERE ENAME = p_ename;
       RETURN v_salary;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RETURN NULL;
     END get_salary;
   END emp_salary_info;
   /
   
   -- Examples of execution
   SELECT emp_salary_info.get_salary(7369) FROM DUAL;
   SELECT emp_salary_info.get_salary('SMITH') FROM DUAL;

-- Paquete de acceso a datos – departamento
-- Se requiere mejorar el control del acceso a datos para la tabla departamentos (dept)
-- encapsulando la lógica y la estructura de la tabla por medio de un paquete de acceso a
-- datos.

CREATE SEQUENCE DEPT_SEQ
MINVALUE 1
MAXVALUE 9999
INCREMENT BY 1
START WITH 1;

CREATE OR REPLACE PACKAGE dept_data_access AS
     TYPE dept_record_type IS RECORD (
       DEPTNO NUMBER(2),
       DNAME VARCHAR2(14),
       LOC VARCHAR2(13)
     );
     TYPE dept_table_type IS TABLE OF dept_record_type INDEX BY PLS_INTEGER;
   
     FUNCTION get_dept_by_id(p_deptno IN NUMBER) RETURN dept_record_type;
     FUNCTION get_all_depts RETURN dept_table_type;
     PROCEDURE insert_dept(p_dname IN VARCHAR2, p_loc IN VARCHAR2);
     PROCEDURE update_dept(p_deptno IN NUMBER, p_dname IN VARCHAR2, p_loc IN VARCHAR2);
     PROCEDURE delete_dept(p_deptno IN NUMBER);
   END dept_data_access;
   /
   
   CREATE OR REPLACE PACKAGE BODY dept_data_access AS
     FUNCTION get_dept_by_id(p_deptno IN NUMBER) RETURN dept_record_type IS
       v_dept dept_record_type;
     BEGIN
       SELECT DEPTNO, DNAME, LOC INTO v_dept.DEPTNO, v_dept.DNAME, v_dept.LOC
       FROM DEPT
       WHERE DEPTNO = p_deptno;
       RETURN v_dept;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RETURN NULL;
     END get_dept_by_id;
   
     FUNCTION get_all_depts RETURN dept_table_type IS
       v_depts dept_table_type;
       v_index PLS_INTEGER := 1;
     BEGIN
       FOR dept_rec IN (SELECT DEPTNO, DNAME, LOC FROM DEPT) LOOP
         v_depts(v_index).DEPTNO := dept_rec.DEPTNO;
         v_depts(v_index).DNAME := dept_rec.DNAME;
         v_depts(v_index).LOC := dept_rec.LOC;
         v_index := v_index + 1;
       END LOOP;
       RETURN v_depts;
     END get_all_depts;
   
     PROCEDURE insert_dept(p_dname IN VARCHAR2, p_loc IN VARCHAR2) IS
     BEGIN
       INSERT INTO DEPT (DEPTNO, DNAME, LOC)
       VALUES (DEPT_SEQ.NEXTVAL, p_dname, p_loc); -- Assuming DEPT_SEQ is a sequence for DEPTNO
       COMMIT;
     END insert_dept;
   
     PROCEDURE update_dept(p_deptno IN NUMBER, p_dname IN VARCHAR2, p_loc IN VARCHAR2) IS
     BEGIN
       UPDATE DEPT SET DNAME = p_dname, LOC = p_loc
       WHERE DEPTNO = p_deptno;
       COMMIT;
     END update_dept;
   
     PROCEDURE delete_dept(p_deptno IN NUMBER) IS
     BEGIN
       DELETE FROM DEPT WHERE DEPTNO = p_deptno;
       COMMIT;
     END delete_dept;
   END dept_data_access;
   /
   
   -- Examples of usage
   DECLARE
     v_dept dept_data_access.dept_record_type;
     v_depts dept_data_access.dept_table_type;
   BEGIN
     v_dept := dept_data_access.get_dept_by_id(10);
     DBMS_OUTPUT.PUT_LINE('Dept Name: ' || v_dept.DNAME);
   
     v_depts := dept_data_access.get_all_depts;
     FOR i IN 1..v_depts.COUNT LOOP
       DBMS_OUTPUT.PUT_LINE('Dept Loc: ' || v_depts(i).LOC);
     END LOOP;
   
     dept_data_access.insert_dept('SUPPORT', 'DENVER');
     dept_data_access.update_dept(50, 'SUPPORT', 'DENVER');
     dept_data_access.delete_dept(50);
   END;
   /


   