--
/*
1. La cláusula `WITH Numbers AS` define una CTE(Expresiond de tabla común) llamada «Numbers» que contiene un conjunto 
    de valores enteros. Algunos de estos valores se repiten para ilustrar el comportamiento 
    de la función RANK().
2. La sentencia `SELECT` recupera los valores de la CTE «Números» y calcula 
    el rango de cada valor utilizando la función analítica RANK().
    - La cláusula `RANK() OVER (ORDER BY x ASC)` asigna un rango a cada valor de «x» 
      en orden ascendente. Si hay valores duplicados, se les asigna el mismo 
      rango, y se salta el rango siguiente (es decir, crea huecos en la clasificación).
3. La salida de la consulta incluye:
    - El valor original de «x».
    - El rango asignado a cada valor basado en el orden ascendente de «x».
*/
WITH Numbers AS
(SELECT 1 as x
UNION ALL SELECT 2
UNION ALL SELECT 2
UNION ALL SELECT 5
UNION ALL SELECT 8
UNION ALL SELECT 10
UNION ALL SELECT 10
UNION ALL SELECT 10
UNION ALL SELECT 11
)
SELECT x,
RANK() OVER (ORDER BY x ASC) AS rank
FROM Numbers;

--EJERCICIO 2
/*

1. La cláusula WITH define una CTE llamada "Numbers" que contiene un conjunto de valores enteros.
    - La CTE incluye valores duplicados (por ejemplo, 2 y 10 aparecen más de una vez).

2. La sentencia SELECT recupera los valores de la CTE "Numbers" y calcula el
    rango denso para cada valor utilizando la función analítica DENSE_RANK().
    - La función DENSE_RANK() asigna un rango único a cada valor distinto en la
      columna "x", ordenado de forma ascendente.
    - A diferencia de RANK(), DENSE_RANK() no deja huecos en la secuencia de clasificación cuando
      se encuentran valores duplicados.

3. La salida de la consulta incluye:
    - El valor original de "x".
    - El rango denso asignado a cada valor basado en el orden ascendente de "x".
*/
WITH Numbers AS
(SELECT 1 as x
UNION ALL SELECT 2
UNION ALL SELECT 2
UNION ALL SELECT 5
UNION ALL SELECT 8
UNION ALL SELECT 10
UNION ALL SELECT 10
)
SELECT x,
DENSE_RANK() OVER (ORDER BY x ASC) AS dense_rank
FROM Numbers;

--ejericio3 

/*
Este script SQL calcula el rango de los participantes en una carrera basado en sus tiempos de llegada,
particionados por sus respectivas divisiones. El script utiliza una Expresión de Tabla Común (CTE)
llamada `finishers` para definir un conjunto de datos de participantes, incluyendo sus nombres, tiempos de llegada,
y divisiones. La consulta principal selecciona lo siguiente:

1. `name`: El nombre de la persona.
2. `finish_time`: La marca de tiempo que indica cuándo el participante terminó la carrera.
3. `division`: La categoría de división del participante (por ejemplo, F30-34, F35-39).
4. `finish_rank`: El rango del participante dentro de su división, calculado usando la
    función de ventana `RANK()`. La clasificación se determina ordenando los tiempos de llegada en
    orden ascendente dentro de cada división.

La función `RANK()` asegura que los participantes con el mismo tiempo de llegada reciban el mismo rango,
y los rangos posteriores se ajustan en consecuencia (es decir, pueden ocurrir espacios en la clasificación).
*/
WITH finishers AS
(SELECT 'Sophia Liu' as name,
TIMESTAMP '2016-10-18 2:51:45' as finish_time,'F30-34' as division
UNION ALL SELECT 'Lisa Stelzner', TIMESTAMP '2016-10-18 2:54:11', 'F35-39'
UNION ALL SELECT 'Nikki Leith', TIMESTAMP '2016-10-18 2:59:01', 'F30-34'
UNION ALL SELECT 'Lauren Matthews', TIMESTAMP '2016-10-18 3:01:17', 'F35-39'
UNION ALL SELECT 'Desiree Berry', TIMESTAMP '2016-10-18 3:05:42', 'F35-39'
UNION ALL SELECT 'Suzy Slane', TIMESTAMP '2016-10-18 3:06:24', 'F35-39'
UNION ALL SELECT 'Jen Edwards', TIMESTAMP '2016-10-18 3:06:36', 'F30-34'
UNION ALL SELECT 'Meghan Lederer', TIMESTAMP '2016-10-18 2:59:01', 'F30-34')
SELECT
name,
finish_time,
division,
RANK() OVER (PARTITION BY division ORDER BY finish_time ASC) AS finish_rank
FROM finishers;


--Ejercicio 4
/*
Este script calcula el rango percentil de los participantes en una carrera basado en sus tiempos de llegada,
particionados por sus respectivas divisiones. El script utiliza una Expresión de Tabla Común (CTE)
llamada `finishers` para definir un conjunto de datos de participantes, sus tiempos de llegada y sus divisiones.

Componentes Clave:
1. `WITH finishers AS (...)`:
    - Define una CTE que contiene una lista de participantes con sus nombres, tiempos de llegada y divisiones.
    - El conjunto de datos incluye participantes de dos divisiones: 'F30-34' y 'F35-39'.

2. `PERCENT_RANK()`:
    - Una función de ventana utilizada para calcular el rango relativo de cada participante dentro de su división.
    - El rango se calcula en base al `finish_time` en orden ascendente.

3. `PARTITION BY division`:
    - Divide el conjunto de datos en grupos basados en la columna `division`.
    - La función `PERCENT_RANK()` se aplica independientemente dentro de cada división.

4. `ORDER BY finish_time ASC`:
    - Especifica que la clasificación debe basarse en el `finish_time` en orden ascendente.

Salida:
- La consulta devuelve las siguientes columnas:
  - `name`: El nombre del participante.
  - `finish_time`: El tiempo de llegada del participante.
  - `division`: La división a la que pertenece el participante.
  - `finish_rank`: El rango percentil del participante dentro de su división.
*/
WITH finishers AS
(SELECT 'Sophia Liu' as name,
TIMESTAMP '2016-10-18 2:51:45' as finish_time,
'F30-34' as division
UNION ALL SELECT 'Lisa Stelzner', TIMESTAMP '2016-10-18 2:54:11', 'F35-39'
UNION ALL SELECT 'Nikki Leith', TIMESTAMP '2016-10-18 2:59:01', 'F30-34'
UNION ALL SELECT 'Lauren Matthews', TIMESTAMP '2016-10-18 3:01:17', 'F35-39'
UNION ALL SELECT 'Desiree Berry', TIMESTAMP '2016-10-18 3:05:42', 'F35-39'
UNION ALL SELECT 'Suzy Slane', TIMESTAMP '2016-10-18 3:06:24', 'F35-39'
UNION ALL SELECT 'Jen Edwards', TIMESTAMP '2016-10-18 3:06:36', 'F30-34'
UNION ALL SELECT 'Meghan Lederer', TIMESTAMP '2016-10-18 2:59:01', 'F30-34')
SELECT name,
finish_time,
division,
PERCENT_RANK() OVER (PARTITION BY division ORDER BY finish_time ASC) AS
finish_rank
FROM finishers;