/**** 1. Listar usuarios que cumplan años hoy y que hayan vendido más de 1500 veces en enero 2020 ****/

SELECT c.cust_id
      ,c.cust_nombre
      ,c.cust_apellido
      ,count (distinct o.order_id) AS camtidad_ordenes_vendidas
FROM `SBOX_PF_MKT.challenge_de_orders` AS o
JOIN `SBOX_PF_MKT.challenge_de_customenrs`AS c ON i.cust_id = o.order_cust_id_sel -- Unimos por seller porque pide usuarios que vendieron
WHERE DATE(c.cust_fecha_nac) = CURRENT_DATE()
      AND DATE(o.order_fecha_creacion) BETWEEN '2020-01-01' AND '2020-01-31' -- ordenes en enero 2020
      AND o.order_estado IN ("cerrada") -- verificamos que se hayan concretado
GROUP BY c.cust_id, c.cust_nombre, c.cust_apellido
ORDER BY 4 DESC -- ordenamos dejando primero al vendedor con mar ordenes
HAVING COUNT(o.order_id) > 1500;

/**** 2. Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la categoría Celulares.
 Se requiere el mes y año de análisis, nombre y apellido del vendedor, cantidad de ventas realizadas,
  cantidad de productos vendidos y el monto total transaccionado.  ****/

WITH orders_agrup AS -- Creo tabla volatil para poder agrupar por periodo, vendedores y categoria solicitada
(
    SELECT 
        EXTRACT(YEAR FROM o.order_date) AS anio
        ,EXTRACT(MONTH FROM o.order_date) AS mes
        ,CONCAT ((YEAR FROM o.order_date), (MONTH FROM o.order_date)) AS anio_mes -- campo para identificar año y mes juntos "YYYYMM"
        ,c.cust_id -- agrego el id unico por si hay nombre y apellidos repetidos
        ,c.cust_nombre AS nombre_vendedor
        ,c.cust_apellido AS apellido_vendedor
        ,COUNT(distinct o.order_id) AS cantidad_ordenes
        ,SUM(o.order_quantity) AS cantidad_productos
        ,SUM(o.order_valor) AS monto_total
    FROM `SBOX_PF_MKT.orders` AS o
    JOIN `SBOX_PF_MKT.categories` AS cat ON o.category_id = cat.category_id
    JOIN `SBOX_PF_MKT.customers` AS c ON o.order_cust_id_sel = c.cust_id -- Unimos por seller porque pide usuarios que vendiero
    WHERE cat.category_g3 = "Celulares"
    AND EXTRACT(YEAR FROM o.order_date) = 2020
    GROUP BY ALL
    ORDER BY 3, 6 DESC -- -- ordenamos dejando primero al vendedor con mar ordenes por periodo
)

SELECT anio
      ,mes
      ,anio_mes
      ,cust_id,
      ,nombre_vendedor
      ,apellido_vendedor
      ,cantidad_ordenes
      ,cantidad_productos
      ,monto_total
FROM orders_agrup
QUALIFY ROW_NUMBER() OVER (PARTITION BY anio_mes ORDER BY monto_total DESC) <= 5; -- con el qualifi agrupo por periodo, ordeno por monto vendido con el mayo primero y me quedo con los primeros 5 vendedores

/**** 3. Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día.
Tener en cuenta que debe ser reprocesable. Vale resaltar que en la tabla Item,
vamos a tener únicamente el último estado informado por la PK definida. (Se puede resolver a través de StoredProcedure) ****/

CREATE OR REPLACE PROCEDURE `SBOX_PF_MKT.reproceso_item_history`()
BEGIN
    -- Elimino registros previos del mismo día para ser reprocesable
    DELETE FROM `SBOX_PF_MKT.challenge_de_item_history`
    WHERE DATE(item_fecha_registro) = CURRENT_DATE();

    -- Inserta el estado actual de cada ítem en la tabla histórica
    INSERT INTO `SBOX_PF_MKT.item_history` (item_id, item_precio, item_estado, item_fecha_registro)
    SELECT item_id, item_precio, item_estado, CURRENT_TIMESTAMP()
    FROM `SBOX_PF_MKT.challenge_de_items`;
END;

-- en MELI haria esta actualizacion dentro de un job en data suite, para programar una actualizacion con la periodicidad que se requiera