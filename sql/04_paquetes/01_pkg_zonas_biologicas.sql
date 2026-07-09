-- Paquete 1/10: zonas_biologicas
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 01_pkg_zonas_biologicas.sql

SET TERM ^ ;

CREATE PACKAGE pkg_zonas_biologicas
SQL SECURITY DEFINER
AS
BEGIN
  PROCEDURE sp_zona_insertar(nombre VARCHAR(80), descripcion VARCHAR(255))
    RETURNS (id_zona INTEGER);
  PROCEDURE sp_zona_actualizar(id_zona INTEGER, nombre VARCHAR(80), descripcion VARCHAR(255));
  PROCEDURE sp_zona_eliminar(id_zona INTEGER);
  PROCEDURE sp_zona_listar
    RETURNS (id_zona INTEGER, nombre VARCHAR(80), descripcion VARCHAR(255));

  FUNCTION fn_zona_existe(id_zona INTEGER) RETURNS BOOLEAN;
END^

CREATE PACKAGE BODY pkg_zonas_biologicas
AS
BEGIN
  PROCEDURE sp_zona_insertar(nombre VARCHAR(80), descripcion VARCHAR(255))
    RETURNS (id_zona INTEGER)
  AS
  BEGIN
    INSERT INTO zonas_biologicas (nombre, descripcion)
      VALUES (:nombre, :descripcion)
      RETURNING id_zona INTO :id_zona;
  END

  PROCEDURE sp_zona_actualizar(id_zona INTEGER, nombre VARCHAR(80), descripcion VARCHAR(255))
  AS
  BEGIN
    UPDATE zonas_biologicas SET nombre = :nombre, descripcion = :descripcion
      WHERE zonas_biologicas.id_zona = :id_zona;
  END

  PROCEDURE sp_zona_eliminar(id_zona INTEGER)
  AS
  BEGIN
    DELETE FROM zonas_biologicas WHERE zonas_biologicas.id_zona = :id_zona;
  END

  PROCEDURE sp_zona_listar
    RETURNS (id_zona INTEGER, nombre VARCHAR(80), descripcion VARCHAR(255))
  AS
  BEGIN
    FOR SELECT z.id_zona, z.nombre, z.descripcion
        FROM zonas_biologicas z
        ORDER BY z.nombre
        AS CURSOR c_zonas
    DO
    BEGIN
      id_zona = c_zonas.id_zona;
      nombre = c_zonas.nombre;
      descripcion = c_zonas.descripcion;
      SUSPEND;
    END
  END

  FUNCTION fn_zona_existe(id_zona INTEGER) RETURNS BOOLEAN
  AS
  BEGIN
    RETURN EXISTS(SELECT 1 FROM zonas_biologicas z WHERE z.id_zona = :id_zona);
  END
END^

SET TERM ; ^

COMMIT;
