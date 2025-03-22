SELECT *
FROM employees
FETCH NEXT 10 ROWS ONLY;

SELECT *
FROM employees
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;

SELECT *
FROM employees
OFFSET 20 ROWS
FETCH NEXT 10 ROWS ONLY;

SELECT *
FROM employees
OFFSET 100 ROWS
FETCH NEXT 10 ROWS ONLY;

SELECT *
FROM employees
OFFSET 110 ROWS
FETCH NEXT 10 ROWS ONLY;

SELECT
 n, 
 CASE 0 
 WHEN "3" + "5" THEN 'FizzBuzz' 
 WHEN "3" THEN 'Fizz' 
 WHEN "5" THEN 'Buzz' 
 ELSE '' || n 
 END 
FROM 
( 
 SELECT 
 level n, mod(level,3) "3", mod(level, 5) "5" 
 FROM 
 dual 
 CONNECT BY level<=100
);

SELECT CASE sum(nvl2(nullif(mod(:n, level), 0), 0, 1))
 WHEN 1 THEN 'Yes'
 ELSE 'No'
 END "Is prime?"
FROM dual
CONNECT BY level < :n; -- ":n" nos permite ingresar un valor en tiempo de ejecución 

SELECT employee_id, last_name, manager_id
FROM employees
CONNECT BY PRIOR employee_id = manager_id;

SELECT employee_id, last_name, manager_id, LEVEL
FROM employees
CONNECT BY PRIOR employee_id = manager_id;

SELECT last_name, employee_id, manager_id, LEVEL
FROM employees
START WITH employee_id = 100
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY last_name;

SELECT last_name "Employee", 
 LEVEL, SYS_CONNECT_BY_PATH(last_name, '/') "Path"
FROM employees
WHERE level <= 3 AND department_id = 80
START WITH last_name = 'King'
CONNECT BY PRIOR employee_id = manager_id AND LEVEL <= 4;

SELECT last_name "Employee", CONNECT_BY_ISCYCLE "Cycle",
 LEVEL, SYS_CONNECT_BY_PATH(last_name, '/') "Path"
FROM employees
WHERE level <= 3 AND department_id = 80
START WITH last_name = 'King'
CONNECT BY NOCYCLE PRIOR employee_id=manager_id AND LEVEL<=4;


WITH generator ( value ) AS
(
    SELECT 1 FROM DUAL
    UNION ALL
    SELECT value + 1
    FROM generator
    WHERE value < 10
)
SELECT value
FROM generator;

SELECT manager_id, department_id, Sum(salary)
FROM employees
GROUP BY manager_id, department_id
ORDER BY manager_id;

SELECT manager_id, department_id, Sum(salary)
FROM employees
GROUP BY Rollup(manager_id, department_id)
ORDER BY manager_id;-- recomendación de profe, contar las filas de la tabla para ver diferencias


SELECT department_id "Dept.",
 LISTAGG(last_name, '; ')
 WITHIN GROUP (ORDER BY hire_date) "Employees"
FROM employees
GROUP BY department_id
ORDER BY department_id;

SELECT LISTAGG(department_id, ''''||','||'''') 
 WITHIN GROUP (ORDER BY department_id)
FROM departments;

SELECT department_id AS dept, last_name, 
 LISTAGG(last_name, ' | ')
 WITHIN GROUP (ORDER BY hire_date) 
 OVER (PARTITION BY department_id) AS emp_list
FROM employees
ORDER BY department_id;


SELECT department_id AS dept, last_name,
 ROW_NUMBER() 
 OVER (PARTITION BY department_id 
 ORDER BY hire_date) row_order,
 LISTAGG(last_name, ' | ')
 WITHIN GROUP (ORDER BY hire_date) 
 OVER (PARTITION BY department_id) AS emp_list
FROM employees
ORDER BY department_id;


--sql windows
SELECT employee_id, last_name, department_id, hire_date
FROM employees;

SELECT employee_id, last_name, department_id, hire_date,
 Lead(hire_date) OVER (PARTITION BY department_id
 ORDER BY hire_date) next_hire
FROM employees;

SELECT employee_id, last_name, department_id, hire_date,
 Lead(hire_date) OVER (PARTITION BY department_id
 ORDER BY hire_date) next_hire,
 Lead(hire_date) OVER (PARTITION BY department_id 
 ORDER BY hire_date) - hire_date interval_in_days
FROM employees;


SELECT employee_id, last_name, department_id, hire_date,
 Lead(hire_date) OVER (PARTITION BY department_id
 ORDER BY hire_date) next_hire,
 Lead(hire_date) OVER (PARTITION BY department_id
 ORDER BY hire_date) - hire_date interval_days,
 hire_date - Min(hire_date) OVER (PARTITION BY department_id
 ORDER BY hire_date) lapse_days
FROM employees;


SELECT * FROM
( 
    SELECT to_char(hire_date, 'MONTH'), department_id 
    FROM employees
)
PIVOT
    ( Count(department_id) 
    FOR (department_id) 
    IN ('10','20','30','40','50','60','70','80','90',
    '100','110','120','130','140','150','160','170',
    '180','190','200','210','220','230','240','250',
    '260','270')
);

SELECT * FROM
( 
    SELECT to_char(hire_date, 'MONTH'), department_id ,salary
    FROM employees
)
PIVOT
    ( SUM(salary) 
    FOR (department_id) 
    IN ('10','20','30','40','50','60','70','80','90',
    '100','110','120','130','140','150','160','170',
    '180','190','200','210','220','230','240','250',
    '260','270')
);

SELECT * FROM
( 
    SELECT to_char(hire_date, 'MONTH'), department_id ,salary
    FROM employees
)
PIVOT(
SUM(salary)
    FOR (department_id) 
    IN ('10','20','30','40','50','60','70','80','90',
    '100','110','120','130','140','150','160','170',
    '180','190','200','210','220','230','240','250',
    '260','270')
);