-- a) Proyecte los nombres y apellidos de los empleados que han tenido al menos un
-- cambio de trabajo (JOB)
SELECT DISTINCT e.first_name, e.last_name
FROM employees e
JOIN job_history jh ON e.employee_id = jh.employee_id;

-- b) Averigüe y proyecte cuáles son los empleados que solo hayan tenido un cargo o
-- trabajo (JOB).
SELECT e.first_name, e.last_name
FROM employees e
WHERE e.employee_id NOT IN (SELECT employee_id FROM job_history);

-- c) Averigüe y proyecte cuál es la cantidad de trabajos que ha tenido cada uno de
-- los empleados.
SELECT e.first_name, e.last_name, COUNT(jh.job_id) AS number_of_jobs
FROM employees e
LEFT JOIN job_history jh ON e.employee_id = jh.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY e.first_name, e.last_name;

-- d) Proyecta los departamentos con la lista de los meses en que los empleados
-- cumplen aniversario de contratación. La lista va al frente del código del
-- departamento y está separada por comas.
SELECT d.department_id,
       LISTAGG(TO_CHAR(e.hire_date, 'MM'), ', ') WITHIN GROUP (ORDER BY TO_CHAR(e.hire_date, 'MM')) AS anniversary_months
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id
ORDER BY d.department_id;

-- e) Seleccione los empleados que cumplen aniversario de trabajo en el mes de mayo
-- y proyecte su email, nombre, día y mes de ingreso a trabajar.
SELECT email, first_name, TO_CHAR(hire_date, 'DD') AS hire_day, TO_CHAR(hire_date, 'MM') AS hire_month
FROM employees
WHERE TO_CHAR(hire_date, 'MM') = '05';

-- f) Seleccione los empleados cuyo nombre y apellido inicien por la misma letra y
-- proyecte el ID, nombre y apellido todo en mayúsculas.
SELECT UPPER(e.employee_id) AS ID, UPPER(e.first_name) AS Nombre, UPPER(e.last_name) AS Apellido
FROM employees e
WHERE SUBSTR(e.first_name, 1, 1) = SUBSTR(e.last_name, 1, 1);

-- g) Seleccione los empleados que ingresaron a trabajar en el mismo mes del mes
-- actual y proyectar un saludo que diga: “Estimado NOMBRE, es para nosotros
-- un gusto que hayas compartido con nosotros durante los últimos X días.
-- Queremos expresarte que puedes contar con nosotros y que contamos contigo.
-- Por favor pasa el ULTIMO_DIA_DEL MES por el salón principal para la
-- reunión de celebración”.
SELECT 'Estimado ' || e.first_name || ', es para nosotros un gusto que hayas compartido con nosotros durante los últimos ' ||
       (TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM') || '-' || TO_CHAR(LAST_DAY(SYSDATE), 'DD'), 'YYYY-MM-DD') - e.hire_date) || ' días. ' ||
       'Queremos expresarte que puedes contar con nosotros y que contamos contigo. Por favor pasa el ' ||
       TO_CHAR(LAST_DAY(SYSDATE), 'DD') || ' por el salón principal para la reunión de celebración.' AS saludo
FROM employees e
WHERE TO_CHAR(e.hire_date, 'MM') = TO_CHAR(SYSDATE, 'MM');

-- h) Proyecta el ID, nombre, apellido, salario y experiencia. La experiencia se
-- determina en 1, 2, 3 o 4 así:
-- Antigüedad Rango
-- [0, 5) años 1
-- [5, 10) años 2
-- [10,15) años 3
-- [15, ∞) años 4
SELECT employee_id, first_name, last_name, salary,
       CASE
           WHEN MONTHS_BETWEEN(SYSDATE, hire_date) / 12 < 5 THEN 1
           WHEN MONTHS_BETWEEN(SYSDATE, hire_date) / 12 >= 5 AND MONTHS_BETWEEN(SYSDATE, hire_date) / 12 < 10 THEN 2
           WHEN MONTHS_BETWEEN(SYSDATE, hire_date) / 12 >= 10 AND MONTHS_BETWEEN(SYSDATE, hire_date) / 12 < 15 THEN 3
           ELSE 4
       END AS experience
FROM employees;

-- i)Determine, para un año completo, el calendario mensual de pagos de
-- bonificaciones por antigüedad a los empleados. El horizonte de tiempo a presentar
-- va de enero a diciembre. El bono de antigüedad se paga mes vencido, es decir, el
-- mes siguiente al mes en el que se cumple el aniversario laboral. La información se
-- espera tabular, teniendo en las filas los departamentos, identificados por su id, y en
-- las columnas los meses.
WITH Months AS (
    -- Genera una serie de números del 1 al 12 representando los meses
    SELECT LEVEL AS month_number
    FROM dual
    CONNECT BY LEVEL <= 12
),
EmployeeAnniversaries AS (
    -- Calcula el mes de aniversario laboral para cada empleado
    SELECT
        e.department_id,
        TO_NUMBER(TO_CHAR(e.hire_date, 'MM')) AS anniversary_month
    FROM employees e
),
BonusPaymentSchedule AS (
    -- Determina el mes en que se paga la bonificación (mes siguiente al aniversario)
    SELECT
        ea.department_id,
        m.month_number AS payment_month
    FROM EmployeeAnniversaries ea
    JOIN Months m ON m.month_number = MOD(ea.anniversary_month, 12) + 1
)
-- Pivota los resultados para tener los departamentos como filas y los meses como columnas
SELECT *
FROM (
    SELECT
        bps.department_id,
        TO_CHAR(TO_DATE(bps.payment_month, 'MM'), 'Month') AS payment_month
    FROM BonusPaymentSchedule bps
)
PIVOT (
    COUNT(*)
    FOR payment_month IN ('January' AS "01", 'February' AS "02", 'March' AS "03",
                           'April' AS "04", 'May' AS "05", 'June' AS "06",
                           'July' AS "07", 'August' AS "08", 'September' AS "09",
                           'October' AS "10", 'November' AS "11", 'December' AS "12")
)
ORDER BY department_id;


-- j) Determine las fechas de cumplimiento de aniversario de contratación de cada
-- uno de los funcionarios. Con estas fechas presente en un listado de fechas de
-- aniversarios de los empleados a ocurrir en el año inmediatamente siguiente. Se
-- necesita conocer el ID, el nombre, la fecha de ingreso, la fecha en que cumplirá
-- años y la fecha del viernes inmediatamente siguiente, que es el día de la
-- celebración.hire
SELECT employee_id,
       first_name,
       hire_date,
       ADD_MONTHS(hire_date, (EXTRACT(YEAR FROM SYSDATE) + 1 - EXTRACT(YEAR FROM hire_date)) * 12) AS anniversary_date,
       NEXT_DAY(ADD_MONTHS(hire_date, (EXTRACT(YEAR FROM SYSDATE) + 1 - EXTRACT(YEAR FROM hire_date)) * 12), 'FRIDAY') AS celebration_date
FROM employees;

-- k) Determine como y que hace el siguiente “Query”. También identifique opción de
-- mejora, si la hay:
/*
Esta consulta calcula la suma de los salarios de los empleados, agrupados por departamento y por mes de contratación.
Luego, utiliza la función PIVOT para transformar los meses en columnas.

Análisis paso a paso:
1. La subconsulta interna selecciona el ID del departamento (reemplazando NULL con 0), el mes de contratación y la suma de los salarios.
2. La función GROUP BY CUBE genera todas las posibles combinaciones de agrupamiento para el departamento y el mes, incluyendo totales generales y totales por departamento/mes individualmente.
3. La subconsulta externa utiliza COALESCE para mostrar 'Total' en lugar de 0 para el ID del departamento y 'Total' para los totales de mes.
4. La función PIVOT toma los resultados y crea columnas para cada mes ('01' a '12') y un total general ('Total'), mostrando la suma de los salarios para cada combinación de departamento y mes.
5. Finalmente, la consulta se ordena primero por si el departamento es 'Total' (al final) y luego por el número del departamento.
*/
SELECT *
FROM (
    SELECT
        COALESCE(TO_CHAR(dep), 'Total') dep,
        COALESCE(mes, 'Total') mes,
        sal
    FROM (
        SELECT
            NVL(department_id, 0) dep,
            TO_CHAR(hire_date, 'mm') mes,
            SUM(salary) sal
        FROM employees
        GROUP BY CUBE (NVL(department_id, 0), TO_CHAR(hire_date, 'mm'))
    )
) t
PIVOT (
    SUM(sal)
    FOR mes IN ('01' AS "01", '02' AS "02", '03' AS "03", '04' AS "04",
                '05' AS "05", '06' AS "06", '07' AS "07", '08' AS "08",
                '09' AS "09", '10' AS "10", '11' AS "11", '12' AS "12",
                'Total' AS Total)
)
ORDER BY
    CASE dep WHEN 'Total' THEN 1 ELSE 0 END,
    CASE dep WHEN 'Total' THEN 0 ELSE TO_NUMBER(dep) END;

-- l) Determine como y que hace el siguiente “Query”:
/*
Esta consulta calcula el factorial de un número dado (representado por la variable de sustitución :n).

Análisis paso a paso:
1. `SELECT Exp(Sum(LN(level))) factorial`: Calcula el exponencial de la suma de los logaritmos naturales de los números de nivel. Esta es una forma matemática de calcular el factorial.
   - `level`: Es una pseudocolumna que representa el nivel en una consulta jerárquica.
   - `LN(level)`: Calcula el logaritmo natural de cada nivel.
   - `Sum(LN(level))`: Suma los logaritmos naturales de todos los niveles.
   - `Exp(...)`: Calcula el exponencial de la suma, que es igual al factorial.
2. `from dual`: Se utiliza `dual` como una tabla ficticia necesaria en Oracle para ejecutar una sentencia SELECT que no requiere datos de una tabla real.
3. `connect by level <= :n`: Esta es la cláusula que define una consulta jerárquica.
   - `connect by level <= :n`: Genera filas desde el nivel 1 hasta el valor proporcionado para la variable de sustitución `:n`.

En resumen, esta consulta toma un número como entrada y devuelve su factorial.
*/
SELECT Exp(SUM(LN(level))) factorial
FROM dual
CONNECT BY level <= :n;

-- m) Determine como y que hace el siguiente “Query”:
/*
Esta consulta selecciona los empleados de cada departamento y los lista en una sola fila, separados por "; ".

Análisis paso a paso:
1. `SELECT department_id "Dept.", LISTAGG(last_name, '; ') WITHIN GROUP (ORDER BY hire_date) "Employees"`:
   - `department_id "Dept."`: Selecciona el ID del departamento y le asigna el alias "Dept.".
   - `LISTAGG(last_name, '; ') WITHIN GROUP (ORDER BY hire_date) "Employees"`: Esta es una función de agregación que concatena los valores de la columna `last_name` para cada grupo (definido por `GROUP BY`).
     - `last_name`: La columna que se va a concatenar.
     - `'; '`: El separador que se utilizará entre los nombres.
     - `WITHIN GROUP (ORDER BY hire_date)`: Especifica el orden en que se deben concatenar los nombres dentro de cada grupo (en este caso, por la fecha de contratación).
     - `"Employees"`: El alias asignado a la columna resultante de la concatenación.
2. `FROM employees`: Especifica que los datos se obtienen de la tabla `employees`.
3. `GROUP BY department_id`: Agrupa las filas por el `department_id`, de modo que la función `LISTAGG` opere dentro de cada departamento.
4. `ORDER BY department_id`: Ordena el resultado final por el `department_id`.

En resumen, esta consulta muestra una lista de los apellidos de los empleados para cada departamento, ordenados por su fecha de contratación dentro de cada departamento y separados por punto y coma.
*/
SELECT department_id "Dept.",
       LISTAGG(last_name, '; ')
       WITHIN GROUP (ORDER BY hire_date) "Employees"
FROM employees
GROUP BY department_id
ORDER BY department_id;

-- n) Determine como y que hace el siguiente “Query” en términos que qué selecciona y qué
-- proyecta:
/*
Esta consulta selecciona el nombre completo de los empleados (nombre y apellido) y su ruta jerárquica dentro de la organización, restringiendo los resultados a empleados del departamento 80 y a los tres primeros niveles de la jerarquía.

Análisis paso a paso:
1. `SELECT first_name||' '||last_name "Employee", LEVEL, SYS_CONNECT_BY_PATH(last_name, '/') "Path"`:
   - `first_name||' '||last_name "Employee"`: Concatena el nombre y el apellido del empleado, separados por un espacio, y le asigna el alias "Employee".
   - `LEVEL`: Es una pseudocolumna que indica el nivel jerárquico de cada fila en la consulta jerárquica. El empleado de inicio tiene el nivel 1, sus subordinados el nivel 2, y así sucesivamente.
   - `SYS_CONNECT_BY_PATH(last_name, '/') "Path"`: Esta función construye una cadena de texto que representa la ruta desde la raíz de la jerarquía hasta el empleado actual. Los apellidos de los empleados en la ruta se separan por una barra diagonal '/'.
2. `FROM employees`: Especifica que los datos se obtienen de la tabla `employees`.
3. `WHERE level <= 3 AND department_id = 80`: Filtra los resultados para incluir solo a los empleados cuyo nivel jerárquico sea menor o igual a 3 y que pertenezcan al departamento con `department_id` igual a 80.
4. `START WITH last_name = 'King'`: Define la fila de inicio de la jerarquía. En este caso, comienza con el empleado cuyo apellido es 'King'.
5. `CONNECT BY PRIOR employee_id = manager_id AND LEVEL <= 4`: Define la relación jerárquica entre las filas.
   - `PRIOR employee_id = manager_id`: Conecta cada empleado con su gerente. `PRIOR` se refiere a la fila padre en la jerarquía.
   - `AND LEVEL <= 4`: Limita la profundidad de la jerarquía a un máximo de 4 niveles.

En resumen, esta consulta selecciona y proyecta el nombre completo, el nivel jerárquico y la ruta jerárquica (basada en el apellido) de los empleados del departamento 80, comenzando por 'King' y mostrando hasta el tercer nivel de subordinados.
*/
SELECT first_name||' '||last_name "Employee",
       LEVEL, SYS_CONNECT_BY_PATH(last_name, '/') "Path"
FROM employees
WHERE level <= 3 AND department_id = 80
START WITH last_name = 'King'
CONNECT BY PRIOR employee_id = manager_id AND LEVEL <= 4;

-- ñ) Determine como y que hacen los siguientes “Querys” en términos que qué seleccionan y qué
-- proyectan:

-- Primer Query:
/*
Esta consulta selecciona el apellido, el ID del departamento y la cuenta del ID del departamento para cada combinación única de apellido e ID de departamento en la tabla employees.

Análisis paso a paso:
1. `SELECT e.last_name, e.department_id, Count(department_id)`: Selecciona el apellido del empleado, el ID del departamento y la cuenta del ID del departamento.
2. `FROM employees e`: Especifica que los datos se obtienen de la tabla employees, con el alias 'e'.
3. `GROUP BY e.last_name, e.department_id`: Agrupa las filas basándose en las combinaciones únicas de apellido e ID de departamento. La función de agregación `Count(department_id)` cuenta el número de filas en cada grupo.

En resumen, esta consulta proyecta el apellido de cada empleado, el ID de su departamento y cuántas veces aparece esa combinación específica de apellido y departamento en la tabla. Esto podría indicar, por ejemplo, cuántos empleados con el mismo apellido trabajan en el mismo departamento.
*/
SELECT e.last_name, e.department_id, Count(department_id)
FROM employees e
GROUP BY e.last_name, e.department_id;

-- Segundo Query:
/*
Esta consulta selecciona el apellido, el ID del departamento y la cantidad total de empleados en cada departamento.

Análisis paso a paso:
1. `SELECT e.last_name, e.department_id, Count(department_id) OVER (PARTITION BY e.department_id) Quantity`:
   - `e.last_name`: Selecciona el apellido del empleado.
   - `e.department_id`: Selecciona el ID del departamento del empleado.
   - `Count(department_id) OVER (PARTITION BY e.department_id) Quantity`: Esta es una función de ventana que cuenta el número de empleados dentro de cada partición definida por `e.department_id`.
     - `Count(department_id)`: Cuenta las filas.
     - `OVER (PARTITION BY e.department_id)`: Especifica que la cuenta se realiza dentro de cada grupo de filas que comparten el mismo `department_id`.
     - `Quantity`: Es el alias asignado a esta columna calculada.
2. `FROM employees e`: Especifica que los datos se obtienen de la tabla employees, con el alias 'e'.
3. `GROUP BY e.last_name, e.department_id`: Agrupa las filas por apellido e ID de departamento. Aunque se utiliza una función de ventana, es necesario un `GROUP BY` para que cada fila del resultado represente una combinación única de apellido y departamento.

En resumen, esta consulta proyecta el apellido de cada empleado, su ID de departamento y la cantidad total de empleados que hay en ese mismo departamento. La cantidad se repite para cada empleado dentro del mismo departamento.
*/
SELECT e.last_name, e.department_id, Count(department_id) OVER (PARTITION BY
e.department_id) Quantity
FROM employees e
GROUP BY e.last_name, e.department_id;

-- En algunas  consultas fueron realizadas con inteligencia artificial.