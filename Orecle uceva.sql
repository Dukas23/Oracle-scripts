ALTER SESSION SET CURRENT_SCHEMA = HR;

--Proyecte el listado de todas las columnas de todos los empleados.
select * from  employees;

--  Proyecte los empleados, como en el punto anterior, y ordene por nombre y 
-- apellido
select * from employees
order by first_name, last_name;

--Seleccione los empleados para los cuales su nombre empieza por la letra K.
select * from employees
where first_name like 'K%';

--Seleccione los empleados cuyo nombre empieza por la letra K y ordene la 
--proyección igual que el inmediato pasado punto con ordenamiento.
select * from employees
where first_name like 'K%'
order by first_name;

-- Proyecte los IDs de departamentos (departments), con la cantidad de 
--empleados(employees), que hay en cada uno de ellos (los departamentos).

select departments.DEPARTMENT_ID, count(employees.employee_id) as number_employees
from employees
join departments on employees.department_id = departments.department_id
group by departments.DEPARTMENT_ID;

--Averigüe cual es la máxima cantidad máxima de empleados que departamento 
--alguno tenga.
SELECT
    d.DEPARTMENT_NAME,
    COUNT(e.EMPLOYEE_ID) AS NumberOfEmployees
FROM
    DEPARTMENTS d
LEFT JOIN
    EMPLOYEES e ON d.DEPARTMENT_ID = e.DEPARTMENT_ID
GROUP BY
    d.DEPARTMENT_NAME
ORDER BY
    NumberOfEmployees DESC
FETCH FIRST 1 ROWS ONLY;

--Proyecte el ID y nombre de los empleados con el nombre del departamento en el 
--que trabaja. 
select e.employee_id, e.first_name,d.department_name from departments d
join employees e on d.DEPARTMENT_ID = e.DEPARTMENT_ID;

--  Proyecte el número, nombre y salario de los empleados que trabajan en el 
--departamento SALES. 
select e.employee_id, e.first_name, e.salary from departments d
join employees e on d.DEPARTMENT_ID = e.DEPARTMENT_ID
where d.department_name = 'Sales';

--Igual al anterior pero ordenado de mayor a menor salario.
select e.employee_id, e.first_name, e.salary from departments d
join employees e on d.DEPARTMENT_ID = e.DEPARTMENT_ID
where d.department_name = 'Sales'
order by e.salary desc;

--Obtenga el número y nombre de cada empleado junto con su salario y grado 
--salarial (Si falta la tabla de grado salarial, crearla y poblarla conforme se estudió el 
--ejemplo de non-equijoin).
CREATE TABLE SALARY_GRADES (
    GRADE VARCHAR2(1) PRIMARY KEY,  -- Grado salarial (A, B, C, etc.)
    MIN_SALARY NUMBER,             -- Salario mínimo para este grado
    MAX_SALARY NUMBER              -- Salario máximo para este grado
);
INSERT INTO SALARY_GRADES (GRADE, MIN_SALARY, MAX_SALARY) VALUES ('A', 0, 3000);
INSERT INTO SALARY_GRADES (GRADE, MIN_SALARY, MAX_SALARY) VALUES ('B', 3001, 6000);
INSERT INTO SALARY_GRADES (GRADE, MIN_SALARY, MAX_SALARY) VALUES ('C', 6001, 9000);
INSERT INTO SALARY_GRADES (GRADE, MIN_SALARY, MAX_SALARY) VALUES ('D', 9001, 999999); -- Un valor alto para el máximo

SELECT
    e.EMPLOYEE_ID,
    e.FIRST_NAME,
    e.SALARY,
    'Your grade is: ' || sg.GRADE AS SALARY_GRADE  -- Mostramos el grado salarial y le damos un alias
FROM
    EMPLOYEES e
LEFT JOIN
    SALARY_GRADES sg ON e.SALARY BETWEEN sg.MIN_SALARY AND sg.MAX_SALARY;


-- Proyectar el ID, nombre y grado salarial de los empleados que tienen grados 
--salariales 2, 4 o 5. 
SELECT
    e.EMPLOYEE_ID,
    e.FIRST_NAME,
    'Your grade is: ' || sg.GRADE AS SALARY_GRADE  -- Mostramos el grado salarial y le damos un alias
FROM
    EMPLOYEES e
LEFT JOIN
    SALARY_GRADES sg ON e.SALARY BETWEEN sg.MIN_SALARY AND sg.MAX_SALARY
WHERE sg.GRADE IN ('A', 'C', 'D');

--Obtener el ID del departamento con el promedio salarial ordenado de mayor a 
--menor. 
SELECT
    d.department_id,
    round(AVG(e.salary)) AS average_salary 
FROM
    departments d
JOIN
    employees e ON d.DEPARTMENT_ID = e.DEPARTMENT_ID 
GROUP BY
    d.department_id
ORDER BY
    average_salary DESC; 


--Proyectar el nombre del departamento con el promedio salarial ordenado de 
--mayor a menor. 
SELECT
    d.department_name,
    round(AVG(e.salary)) AS average_salary 
FROM
    departments d
JOIN
    employees e ON d.DEPARTMENT_ID = e.DEPARTMENT_ID
group by
    d.department_name
ORDER BY
    average_salary DESC; 
    
    
--Presentar el ID del departamento con la cantidad de empleados del 
--departamento que cuente con el mayor número de empleados. 

 SELECT
    department_id
FROM
    employees
GROUP BY
    department_id
ORDER BY
    COUNT(employee_id) DESC
FETCH FIRST 1 ROWS ONLY;   

--Encuentre los jefes (manager), presentando su ID y nombre, y el nombre del
--departamento donde trabajan.
select d.manager_id, d.department_name, e.first_name
from departments d
join employees e on d.manager_id = e.employee_id;

--Determinar los nombres de cada empleado junto con el grado salarial del
--empleado, el grado salarial del jefe y la diferencia de grado salarial existente con su
--jefe (grado del jefe – grado del empleado).
SELECT 
    e.FIRST_NAME || ' ' || e.LAST_NAME AS employee_name,
    e_grade.GRADE AS employee_grade,
    m_grade.GRADE AS manager_grade,
    m_grade.GRADE || ' - ' || e_grade.GRADE AS grade_difference
FROM 
    EMPLOYEES e
JOIN 
    EMPLOYEES m ON e.MANAGER_ID = m.EMPLOYEE_ID
JOIN 
    SALARY_GRADES e_grade ON e.SALARY BETWEEN e_grade.MIN_SALARY AND e_grade.MAX_SALARY
JOIN 
    SALARY_GRADES m_grade ON m.SALARY BETWEEN m_grade.MIN_SALARY AND m_grade.MAX_SALARY
ORDER BY 
    e.LAST_NAME, e.FIRST_NAME;


--Averiguar los IDs y nombres de los distintos departamentos en donde hay al
--menos un empleado que gana más de 3000 (Que no hayan tuplas repetidas).
select distinct d.department_id, d.department_name 
from departments d
join employees e on d.department_id = e.employee_id
where e.salary > 3000;

--Identificar los IDs y nombres de los distintos departamentos en donde hay al
--menos dos empleados distintos que ganan más de 2500.
select d.department_id, d.department_name
from departments d
join employees e on d.department_id = e.department_id
where e.salary > 2500
group by d.department_id, d.department_name  -- Agrupamos por departamento
having count(distinct e.employee_id) >= 2; -- Filtramos departamentos con al menos 2 empleados distintos

--Encontrar los IDs y nombres de los empleados que ganan más dinero que su
--respectivo jefe.
select e.employee_id, e.first_name
from employees e
join employees m on m.manager_id = e.employee_id
Where e.salary > m.salary; 

--Establecer los IDs y nombres de los departamentos en donde al menos uno de
--los empleados gana más de 3000 informando la cantidad de estos empleados
--identificada para cada departamento.

SELECT
    d.DEPARTMENT_ID,
    d.DEPARTMENT_NAME,
    COUNT(e.EMPLOYEE_ID) AS cantidad_empleados_mas_de_3000
FROM
    DEPARTMENTS d
JOIN
    EMPLOYEES e ON d.DEPARTMENT_ID = e.DEPARTMENT_ID
WHERE
    e.SALARY > 3000
GROUP BY
    d.DEPARTMENT_ID, d.DEPARTMENT_NAME
ORDER BY
    d.DEPARTMENT_NAME;

--Determinar los IDs y nombres de los departamentos en donde todos los
--empleados ganan más de 3000.
SELECT
    d.DEPARTMENT_ID,
    d.DEPARTMENT_NAME
FROM
    DEPARTMENTS d
WHERE NOT EXISTS (
    SELECT 1
    FROM EMPLOYEES e
    WHERE e.DEPARTMENT_ID = d.DEPARTMENT_ID
      AND e.SALARY <= 3000
);

--Determinar los IDs y nombres de los departamentos en donde todos los
--empleados ganan más de 3000 y existe al menos un jefe que gana más de 5000.
SELECT
    d.DEPARTMENT_ID,
    d.DEPARTMENT_NAME
FROM
    DEPARTMENTS d
WHERE NOT EXISTS (
    SELECT 1
    FROM EMPLOYEES e
    WHERE e.DEPARTMENT_ID = d.DEPARTMENT_ID
      AND e.SALARY <= 3000
)
AND EXISTS (
    SELECT 1
    FROM EMPLOYEES e2
    JOIN EMPLOYEES m ON e2.MANAGER_ID = m.EMPLOYEE_ID
    WHERE e2.DEPARTMENT_ID = d.DEPARTMENT_ID
      AND m.SALARY > 5000
);

--Presentar los IDs y nombres de los empleados que no son del departamento 80
--y que ganan más que cualquiera de los empleados del departamento 80.
SELECT
    EMPLOYEE_ID,
    FIRST_NAME
FROM
    EMPLOYEES
WHERE
    DEPARTMENT_ID <> 80
    AND SALARY > (SELECT MAX(SALARY) FROM EMPLOYEES WHERE DEPARTMENT_ID = 80);