CONN AS SYSDBA;  --Todo esto se hace en sql plus, cuando aparezca el apartado de clave, presionar enter.
CONNECT SYS AS SYSDBA;
ALTER SESSION SET "_ORACLE_SCRIPT"= TRUE;
CREATE USER GRUPO02 IDENTIFIED BY clave02;
GRANT DBA TO GRUPO02;
GRANT CREATE SESSION TO GRUPO02;

CREATE TABLESPACE tabla_usuario
	DATAFILE 'C:\proyecto_admin\tabla_usuarios.dbf' SIZE 256M AUTOEXTEND ON;

CREATE TEMPORARY TABLESPACE usuario_temporal
	TEMPFILE 'C:\proyecto_admin\usuario_temporal.dbf' SIZE 100M AUTOEXTEND ON;

ALTER USER GRUPO02 DEFAULT TABLESPACE tabla_usuario;
ALTER USER GRUPO02 TEMPORARY TABLESPACE usuario_temporal;
DISCONNECT;

--Fin SQL PLUS--


--Oracle SQL Developer, establecer conexion con el usuario anteriormente creado--

--Script con los defaults, temporary y fecha de creacion.
SELECT USERNAME,DEFAULT_TABLESPACE,TEMPORARY_TABLESPACE,CREATED
FROM DBA_USERS
WHERE USERNAME = 'GRUPO02';

--Validacion de default TBS
SELECT TABLESPACE_NAME, FILE_NAME, BYTES / 1024 / 1024 AS SIZE_MB,
    AUTOEXTENSIBLE,
    MAXBYTES / 1024 / 1024 AS MAX_SIZE_MB
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME = 'TABLA_USUARIO';

--Validacion de temp TBS    
SELECT u.TEMPORARY_TABLESPACE, t.FILE_NAME, t.BYTES / 1024 / 1024 AS SIZE_MB,
    t.AUTOEXTENSIBLE,
    t.MAXBYTES / 1024 / 1024 AS MAX_SIZE_MB
FROM DBA_USERS u
    JOIN DBA_TEMP_FILES t 
    ON u.TEMPORARY_TABLESPACE = t.TABLESPACE_NAME
    WHERE u.USERNAME = 'GRUPO02';
    

--Creacion de estructura a nivel de tablespaces

CREATE TABLE table_user(
    id_usuario NUMBER,
    nombre VARCHAR2(50), 
    apellido VARCHAR2(50), 
    edad NUMBER, 
    cedula VARCHAR2(15)
) TABLESPACE TABLA_USUARIO;

CREATE INDEX index_user ON table_user (id_usuario) TABLESPACE TABLA_USUARIO;

SELECT INDEX_NAME, TABLE_NAME, TABLESPACE_NAME 
FROM DBA_INDEXES 
WHERE INDEX_NAME = 'INDEX_USER' AND TABLESPACE_NAME = 'TABLA_USUARIO';


--Creacion de Base de datos 



--Tabla puestos--
CREATE TABLE puestos (
    id_puesto NUMBER PRIMARY KEY,
    descripcion_puesto VARCHAR2(50) NOT NULL,
    salario_puesto NUMBER NOT NULL
);
--Tabla puestos--



--Tabla empleados--
CREATE TABLE empleados (
    cedula_empleado VARCHAR2(30) PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL,
    correo_empresa VARCHAR2(30) NOT NULL,
    clave_empresa VARCHAR2(45) NOT NULL,
    id_puesto NUMBER NOT NULL,
    CONSTRAINT fk_empleados_puestos
        FOREIGN KEY (id_puesto)
        REFERENCES puestos (id_puesto)
);
--Tabla empleados--



--Tabla clientes--
CREATE TABLE clientes (
    cedula_cliente VARCHAR2(30) PRIMARY KEY,
    nombre_cliente VARCHAR2(150) NOT NULL
);
--Tabla clientes--



--Tabla proveedores--
CREATE TABLE proveedores (
    id_proveedor VARCHAR2(30) PRIMARY KEY,
    nombre_proveedor VARCHAR2(45) NOT NULL,
    descripcion_material VARCHAR2(45) NOT NULL
);
--Tabla proveedores--



--Tabla provincias--
CREATE TABLE provincias (
    id_provincia NUMBER PRIMARY KEY,
    nombre_provincia VARCHAR2(50) NOT NULL
);
--Tabla provincias--



--Tabla direccion--
CREATE TABLE direccion (
    id_direccion NUMBER PRIMARY KEY,
    id_provincia NUMBER NOT NULL,
    direccion_general VARCHAR2(45) NOT NULL,
    CONSTRAINT fk_direccion_provincias
        FOREIGN KEY (id_provincia)
        REFERENCES provincias (id_provincia)
);
--Tabla direccion--



--direccion_cliente--
CREATE TABLE direccion_cliente (
    cedula_cliente VARCHAR2(15) NOT NULL,
    id_direccion NUMBER NOT NULL,
    PRIMARY KEY (cedula_cliente, id_direccion),
    CONSTRAINT fk_direccion_cliente_clientes1
        FOREIGN KEY (cedula_cliente)
        REFERENCES clientes (cedula_cliente),
    CONSTRAINT fk_direccion_cliente_direccion1
        FOREIGN KEY (id_direccion)
        REFERENCES direccion (id_direccion)
);
--direccion_cliente--



--direccion_proveedor--
CREATE TABLE direccion_proveedor (
    id_proveedor VARCHAR2(30) NOT NULL,
    id_direccion NUMBER NOT NULL,
    PRIMARY KEY (id_proveedor, id_direccion),
    CONSTRAINT fk_direccion_proveedor_proveedores1
        FOREIGN KEY (id_proveedor)
        REFERENCES proveedores (id_proveedor),
    CONSTRAINT fk_direccion_proveedor_direccion1
        FOREIGN KEY (id_direccion)
        REFERENCES direccion (id_direccion)
);
--direccion_proveedor--



--telefonos--
CREATE TABLE telefonos (
    id_telefono NUMBER NOT NULL,
    numero_telefono VARCHAR2(45) NOT NULL,
    PRIMARY KEY (id_telefono)
);
--telefonos--



--telefono_cliente--
CREATE TABLE telefono_cliente (
    telefonos_id_telefono NUMBER NOT NULL,
    clientes_cedula_cliente VARCHAR2(30) NOT NULL,
    PRIMARY KEY (telefonos_id_telefono, clientes_cedula_cliente),
    CONSTRAINT fk_telefono_cliente_telefonos1
        FOREIGN KEY (telefonos_id_telefono)
        REFERENCES telefonos (id_telefono),
    CONSTRAINT fk_telefono_cliente_clientes1
        FOREIGN KEY (clientes_cedula_cliente)
        REFERENCES clientes (cedula_cliente)
);
--telefono_cliente--



--proveedores_telefonos--
CREATE TABLE proveedores_telefonos (
    id_proveedor VARCHAR2(30) NOT NULL,
    id_telefono NUMBER NOT NULL,
    PRIMARY KEY (id_proveedor, id_telefono),
    CONSTRAINT fk_proveedores_telefonos_proveedores1
        FOREIGN KEY (id_proveedor)
        REFERENCES proveedores (id_proveedor),
    CONSTRAINT fk_proveedores_telefonos_telefonos1
        FOREIGN KEY (id_telefono)
        REFERENCES telefonos (id_telefono)
);
--proveedores_telefonos--



--productos--
CREATE TABLE productos (
  id_producto NUMBER NOT NULL,
  descripcion_producto VARCHAR2(100) NOT NULL,
  precio_producto NUMBER NOT NULL,
  PRIMARY KEY (id_producto)
);
--productos--



--inventario--
CREATE TABLE inventario (
  id_proveedor VARCHAR2(30) NOT NULL,
  id_producto NUMBER NOT NULL,
  cantidad NUMBER(8,4) NOT NULL,
  PRIMARY KEY (id_proveedor, id_producto),
  CONSTRAINT fk_proveedores_productos_proveedores1
    FOREIGN KEY (id_proveedor)
    REFERENCES proveedores (id_proveedor),
  CONSTRAINT fk_proveedores_productos_productos1
    FOREIGN KEY (id_producto)
    REFERENCES productos (id_producto)
);
--inventario--



--ventas--
CREATE TABLE ventas (
  id_venta NUMBER NOT NULL,
  monto_factura DECIMAL(6,2) NOT NULL,
  fecha_venta DATE NOT NULL,
  cedula_cliente VARCHAR2(30) NOT NULL,
  cedula_empleado VARCHAR2(30) NOT NULL,
  PRIMARY KEY (id_venta),
  CONSTRAINT fk_ventas_clientes1
    FOREIGN KEY (cedula_cliente)
    REFERENCES clientes (cedula_cliente),
  CONSTRAINT fk_ventas_empleados1
    FOREIGN KEY (cedula_empleado)
    REFERENCES empleados (cedula_empleado)
);
--ventas--



--metodos de pago-- 
CREATE TABLE metodos_pago (
    id_metodo NUMBER NOT NULL,
    descripcion VARCHAR2(45) NOT NULL,
    PRIMARY KEY (id_metodo)
);
--metodos de pago-- 



--metodos_venta-- 
CREATE TABLE metodo_venta (
    id_venta NUMBER NOT NULL,
    id_metodo NUMBER NOT NULL,
    PRIMARY KEY (id_venta, id_metodo),
    CONSTRAINT fk_metodo_venta_ventas1
        FOREIGN KEY (id_venta)
        REFERENCES ventas (id_venta),
    CONSTRAINT fk_metodo_venta_metodos_pago1
        FOREIGN KEY (id_metodo)
        REFERENCES metodos_pago (id_metodo)
);
--metodos_venta--



--ventas_prodcuto-- 
CREATE TABLE venta_producto (
  id_venta NUMBER NOT NULL,
  id_producto NUMBER NOT NULL,
  cantidad_producto DECIMAL(8,4) NOT NULL,
  PRIMARY KEY (id_venta, id_producto, cantidad_producto),
  CONSTRAINT fk_venta_prodcuto_ventas1
    FOREIGN KEY (id_venta)
    REFERENCES ventas (id_venta),
  CONSTRAINT fk_venta_prodcuto_productos1
    FOREIGN KEY (id_producto)
    REFERENCES productos (id_producto)
);
--ventas_prodcuto-- 



SELECT TABLE_NAME
FROM DBA_TABLES
WHERE OWNER = 'GRUPO02';


--------BACKUP DE LA BASE--------

--EN CMD--
-- SE ESCRIBE EL SIGUIENTE COMANDO 
/*
EXP <usuario>/<clave> FILE = '<ruta_guardado\BACKUPBD.DMP>' LOG = '<ruta_guardado\LOG_BACKUP.LOG>' OWNER = <usuario>
EXP GRUPO02/clave02 FILE='C:\proyecto_admin\backup\BACKUPBD.DMP' LOG= 'C:\proyecto_admin\backup\LOG_BACKUP.LOG' OWNER = GRUPO02
*/
-- A continuacion se muestran todas las tablas que han sido exportadas, por el momento ninguna tiene datos asi que es correcto que salgan 0 filas exportadas
/*
Exportando los usuarios especificados ...
. exportando acciones y objetos de procedimiento pre-esquema
. exportando nombres de biblioteca de funciones ajenas para el usuario GRUPO02
. exportando sinænimos de tipo p∑blico
. exportando sinænimos de tipo privado
. exportando definiciones de tipos de objetos para el usuario GRUPO02
Exportando los objetos de GRUPO02  ...
. exportando enlaces a la base de datos
. exportando n∑meros de secuencia
. exportando definiciones de cluster
. exportando las tablas de GRUPO02 a trav⁄s de la Ruta de Acceso Convencional ...
. exportando la tabla                       CLIENTES          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla                      DIRECCION          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla              DIRECCION_CLIENTE          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla            DIRECCION_PROVEEDOR          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla                      EMPLEADOS          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla                     INVENTARIO          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla                   METODOS_PAGO          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla                   METODO_VENTA          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla                      PRODUCTOS          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla                    PROVEEDORES          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla          PROVEEDORES_TELEFONOS          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla                     PROVINCIAS          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla                        PUESTOS          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla               TELEFONO_CLIENTE          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla                      TELEFONOS          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla                 VENTA_PRODUCTO          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando la tabla                         VENTAS          0 filas exportadas
EXP-00091: Exportando estad›sticas cuestionables.
. exportando sinænimos
. exportando vistas
. exportando procedimientos almacenados
. exportando operadores
. exportando restricciones de integridad referencial
. exportando disparadores
. exportando tipos de ›ndice
. exportando ›ndices bitmap, funcionales y extensibles
. exportando acciones de posttables
. exportando vistas materializadas
. exportando logs de instantﬂneas
. exportando colas de trabajo
. exportando grupos de refrescamiento y secundarios
. exportando dimensiones
. exportando acciones y objetos de procedimiento post-esquema
. exportando estad›sticas
La exportaciæn ha terminado correctamente pero con advertencias.

*/
--Migracion de la base de datos 
/*

IMP <usuario_destino> FILE = <ruta\BACKUPBD.DMP> FULL= Y 
IMP BRCANTI FILE = C:\proyecto_admin\backup\BACKUPBD.DMP FULL=Y
basicamente es apuntar a la carpeta de backup y ejecutar el comando imp
*/

/*
 importando objetos de GRUPO02 en BRCANTI
. importando la tabla                     "CLIENTES"          0 filas importadas
. importando la tabla                    "DIRECCION"          0 filas importadas
. importando la tabla            "DIRECCION_CLIENTE"          0 filas importadas
. importando la tabla          "DIRECCION_PROVEEDOR"          0 filas importadas
. importando la tabla                    "EMPLEADOS"          0 filas importadas
. importando la tabla                   "INVENTARIO"          0 filas importadas
. importando la tabla                 "METODOS_PAGO"          0 filas importadas
. importando la tabla                 "METODO_VENTA"          0 filas importadas
. importando la tabla                    "PRODUCTOS"          0 filas importadas
. importando la tabla                  "PROVEEDORES"          0 filas importadas
. importando la tabla        "PROVEEDORES_TELEFONOS"          0 filas importadas
. importando la tabla                   "PROVINCIAS"          0 filas importadas
. importando la tabla                      "PUESTOS"          0 filas importadas
. importando la tabla             "TELEFONO_CLIENTE"          0 filas importadas
. importando la tabla                    "TELEFONOS"          0 filas importadas
. importando la tabla               "VENTA_PRODUCTO"          0 filas importadas
. importando la tabla                       "VENTAS"          0 filas importadas
*/

--------BACKUP DE LA BASE--------


--CREACION DE LA VISTA-- 

CREATE OR REPLACE VIEW vista_facturas_fecha AS 
SELECT 
    F.FECHA_VENTA, 
    C.NOMBRE_CLIENTE, 
    F.MONTO_FACTURA
FROM 
    VENTAS F
JOIN CLIENTES C
ON F.CEDULA_CLIENTE = C.CEDULA_CLIENTE;
--CREACION DE LA VISTA-- 

--------JOBS--------
--Primero un alter session para ver la hora, minuto y segundo, esto no afecta al job
Alter session set nls_date_format = 'dd-mm-yyyy hh24:mi:ss';

CREATE TABLE historicos_facturas(
    FECHA_VENTA DATE, 
    NOMBRE_CLIENTE VARCHAR2(100), 
    MONTO_FACTURA NUMBER 
);
--Creacion del job
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'CARGAR_HISTORICOS_FACTURAS',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN INSERT INTO historicos_facturas (fecha_venta, nombre_cliente, monto_factura) SELECT fecha_venta, nombre_cliente, monto_factura FROM vista_facturas_fecha; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0;BYSECOND=0;',
    end_date        => NULL,
    enabled         => TRUE,
    comments        => 'Carga datos de la vista_facturas_fecha a historicos_facturas diariamente a la 1:00 AM.'
  );
END;
 --Compruebo que se haya creado y que estÈ activo
SELECT job_name, start_date, repeat_interval, enabled
FROM user_scheduler_jobs
WHERE job_name = 'CARGAR_HISTORICOS_FACTURAS';
--------JOBS--------
