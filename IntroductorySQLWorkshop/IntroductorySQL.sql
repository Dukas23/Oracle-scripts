ALTER SESSION SET CURRENT_SCHEMA = HR;

-- Find out how many departments exist in the company
SELECT COUNT(DEPARTMENT_ID) FROM DEPARTMENTS;

-- Find out if there are any employees without a manager.
SELECT * FROM EMPLOYEES WHERE MANAGER_ID IS NULL;

--Find out what are the departments that have at least one employee.
SELECT d.department_NAME, COUNT(e.employee_id) AS employee_count
FROM EMPLOYEES e JOIN DEPARTMENTS d
USING (department_id)
GROUP BY d.department_NAME;

--Find out what is the annual salary for each employee.
SELECT LAST_NAME, 12*SALARY AS ANNUAL_SALARY
FROM EMPLOYEES;

--Find out for employees with a firt_name that contains an “r” character.
SELECT FIRST_NAME
FROM employees
WHERE first_name LIKE '%r%';

--Find out what employees are in the department 10 and 100.
SELECT * FROM EMPLOYEES 
WHERE DEPARTMENT_ID IN (10,100);

--Make a projection of employee’s first_name and last_name and order it 
--ascending, taking into account the last_name as the first order key.
SELECT FIRST_NAME, LAST_NAME FROM EMPLOYEES
ORDER BY LAST_NAME;


--Make a projection like the previous one, but adding the employee’s salary formatted using asterisks to complete the 10 character mask.
SELECT FIRST_NAME, LAST_NAME, RPAD(CAST(SALARY AS VARCHAR2(10)), 10, '*') AS PADDED_SALARY
FROM EMPLOYEES
order by last_name;

--Find out what is the date of twentieth anniversary for each employee
SELECT first_name, last_name, hire_date, ADD_MONTHS(hire_date, 240) AS twentieth_anniversary
FROM employees;

--Make a projection of employee’s firt_name, last_name, salary, commision_pct and its respective annual salary taking into account the salary and commission
SELECT  FIRST_NAME, LAST_NAME, SALARY, COMMISSION_PCT, ((SALARY*12)+(NVL2(COMMISSION_PCT,(SALARY* COMMISSION_PCT),0 )*12)) AS ANNUAL_SALARY_WITH_COMMISSION FROM EMPLOYEES;

