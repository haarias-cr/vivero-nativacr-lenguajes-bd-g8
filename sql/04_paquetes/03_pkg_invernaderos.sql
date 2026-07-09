-- Paquete 3/10: invernaderos
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 03_pkg_invernaderos.sql

SET TERM ^ ;

CREATE PACKAGE pkg_invernaderos
SQL SECURITY DEFINER
AS
BEGIN
  PROCEDURE sp_invernadero_insertar(nombre VARCHAR(60), ubicacion VARCHAR(120), capacidad INTEGER)
    RETURNS (id_invernadero INTEGER);
  PROCEDURE sp_invernadero_actualizar(id_invernadero INTEGER, nombre VARCHAR(60),
      ubicacion VARCHAR(120), capacidad INTEGER);
  PROCEDURE sp_invernadero_eliminar(id_invernadero INTEGER);
  PROCEDURE sp_invernadero_listar
    RETURNS (id_invernadero INTEGER, nombre VARCHAR(60), capacidad INTEGER,
      plantas_actuales INTEGER, espacio_disponible INTEGER);

  FUNCTION fn_invernadero_capacidad_disponible(id_invernadero INTEGER) RETURNS INTEGER;
END^

CREATE PACKAGE BODY pkg_invernaderos
AS
BEGIN
  PROCEDURE sp_invernadero_insertar(nombre VARCHAR(60), ubicacion VARCHAR(120), capacidad INTEGER)
    RETURNS (id_invernadero INTEGER)
  AS
  BEGIN
    INSERT INTO invernaderos (nombre, ubicacion, capacidad)
      VALUES (:nombre, :ubicacion, :capacidad)
      RETURNING id_invernadero INTO :id_invernadero;
  END

  PROCEDURE sp_invernadero_actualizar(id_invernadero INTEGER, nombre VARCHAR(60),
      ubicacion VARCHAR(120), capacidad INTEGER)
  AS
  BEGIN
    UPDATE invernaderos SET nombre = :nombre, ubicacion = :ubicacion, capacidad = :capacidad
      WHERE invernaderos.id_invernadero = :id_invernadero;
  END

  PROCEDURE sp_invernadero_eliminar(id_invernadero INTEGER)
  AS
  BEGIN
    DELETE FROM invernaderos WHERE invernaderos.id_invernadero = :id_invernadero;
  END

  PROCEDURE sp_invernadero_listar
    RETURNS (id_invernadero INTEGER, nombre VARCHAR(60), capacidad INTEGER,
      plantas_actuales INTEGER, espacio_disponible INTEGER)
  AS
  BEGIN
    FOR SELECT v.id_invernadero, v.nombre, v.capacidad, v.plantas_actuales, v.espacio_disponible
        FROM v_invernaderos_ocupacion v
        ORDER BY v.nombre
        AS CURSOR c_inv
    DO
    BEGIN
      id_invernadero = c_inv.id_invernadero;
      nombre = c_inv.nombre;
      capacidad = c_inv.capacidad;
      plantas_actuales = c_inv.plantas_actuales;
      espacio_disponible = c_inv.espacio_disponible;
      SUSPEND;
    END
  END

  FUNCTION fn_invernadero_capacidad_disponible(id_invernadero INTEGER) RETURNS INTEGER
  AS
    DECLARE VARIABLE v_capacidad INTEGER;
    DECLARE VARIABLE v_ocupado INTEGER;
    DECLARE VARIABLE v_cantidad_lote INTEGER;
  BEGIN
    v_ocupado = 0;
    SELECT capacidad FROM invernaderos WHERE invernaderos.id_invernadero = :id_invernadero
      INTO :v_capacidad;

    FOR SELECT l.cantidad FROM lotes l
        WHERE l.id_invernadero = :id_invernadero AND l.estado = 'activo'
        AS CURSOR c_lotes
    DO
    BEGIN
      v_cantidad_lote = c_lotes.cantidad;
      v_ocupado = v_ocupado + v_cantidad_lote;
    END

    RETURN v_capacidad - v_ocupado;
  END
END^

SET TERM ; ^

COMMIT;
