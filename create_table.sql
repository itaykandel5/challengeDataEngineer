/**** EL SIGUIENTE CODIGO ESTA PENSADO PARA SER EJECUTADO EN BIGQUERY. ES POR ESTO QUE NO SE DECLARAN PK NI FOREING KEY ****/

##### CREO LA TABLA DE CUSTUMERS #####
CREATE OR REPLACE TABLE `SBOX_PF_MKT.challenge_de_customers`
( 
  cust_id INT64, -- Identificador único por customer (PK)
  cust_email STRING,
  cust_nombre STRING,
  cust_apellido STRING,
  cust_sexo STRING,
  cust_direccion STRING,
  cust_fecha_nac DATE,
  cust_telefono INT64
)
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 500 HOUR));

##### CREO LA TABLA DE ITEMS #####
CREATE OR REPLACE TABLE `SBOX_PF_MKT.challenge_de_items`
( 
  item_id INT64, -- Identificador único por item (PK)
  category_id INT64,-- Clave foranea que identifica la categoria a la que pertenece el item
  item_nombre STRING,
  Item_precio NUMERIC,
  item_descripcion STRING,
  item_fecha_publicacion DATE,
  item_fecha_baja DATE,
  item_estado STRING -- Indica si el item esta "activo" o "inactivo"
)
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 500 HOUR));

##### CREO LA TABLA DE CATEGORIAS #####
CREATE OR REPLACE TABLE `SBOX_PF_MKT.challenge_de_category`
( 
  category_id INT64, -- Identificador único por categoria (PK)
  category_g1 STRING,-- Nombre del primer grupo de agregacion de categoriaa
  category_g2 STRING,-- Nombre de categoria con un nivel mas de desagregacion que g1
  category_g3 STRING -- Nombre de categoria con un nivel mas de desagregacion que g2
)
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 500 HOUR));

##### CREO LA TABLA DE ORDERS #####
CREATE OR REPLACE TABLE `SBOX_PF_MKT.challenge_de_orders`
( 
  order_id INT64, -- Identificador único por order (PK)
  order_fecha_creacion DATE,
  order_cust_id_buy INT64,-- Clave foranea que identifica al customer que realizó la orden
  order_cust_id_sel INT64, -- Clave foranea que identifica al customer al que se le realiza la orden
  order_item_id INT64,-- Clave foranea que identifica el item de la transaccion
  order_item_precio NUMERIC,
  order_item_qty INT64, -- Indicador de la cantidad de items comprados
  order_valor FLOAT64, -- Valor del item multiplicado por la cantidad 
  order_category_id INT64, -- Clave foranea que identifica la categoria a la que pertenece el item
  order_estado STRING -- indica si la orden fue carada con éxito si se encuentra "cerrada" y de nno ser asi, quedará "abierta"
)
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 500 HOUR));

##### CREO HISTORIAL DE ESTADOS Y PRECIOS DE LOS ITEMS #####
CREATE OR REPLACE TABLE `SBOX_PF_MKT.challenge_de_item_history`
(
    item_id INT64,
    item_precio NUMERIC,
    item_estado STRING,
    item_fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 500 HOUR));
