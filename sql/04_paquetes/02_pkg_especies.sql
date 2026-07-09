-- Paquete 2/10: especies
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 02_pkg_especies.sql

SET TERM ^ ;

CREATE PACKAGE pkg_especies
SQL SECURITY DEFINER
AS
BEGIN
  PROCEDURE sp_especie_insertar(id_zona INTEGER, nombre_cientifico VARCHAR(120),
      nombre_comun VARCHAR(80), precio_unitario DECIMAL(10,2), descripcion VARCHAR(1000))
    RETURNS (id_especie INTEGER);
  PROCEDURE sp_especie_actualizar(id_especie INTEGER, nombre_cientifico VARCHAR(120),
      nombre_comun VARCHAR(80), precio_unitario DECIMAL(10,2), descripcion VARCHAR(1000));
  PROCEDURE sp_especie_eliminar(id_especie INTEGER);
  PROCEDURE sp_especie_listar_por_zona(id_zona INTEGER)
    RETURNS (id_especie INTEGER, nombre_comun VARCHAR(80), nombre_cientifico VARCHAR(120),
      precio_unitario DECIMAL(10,2), zona VARCHAR(80));

  FUNCTION fn_especie_precio(id_especie INTEGER) RETURNS DECIMAL(10,2);
  FUNCTION fn_especie_existe(id_especie INTEGER) RETURNS BOOLEAN;
END^

CREATE PACKAGE BODY pkg_especies
AS
BEGIN
  PROCEDURE sp_especie_insertar(id_zona INTEGER, nombre_cientifico VARCHAR(120),
      nombre_comun VARCHAR(80), precio_unitario DECIMAL(10,2), descripcion VARCHAR(1000))
    RETURNS (id_especie INTEGER)
  AS
  BEGIN
    INSERT INTO especies (id_zona, nombre_cientifico, nombre_comun, precio_unitario, descripcion)
      VALUES (:id_zona, :nombre_cientifico, :nombre_comun, :precio_unitario, :descripcion)
      RETURNING id_especie INTO :id_especie;
  END

  PROCEDURE sp_especie_actualizar(id_especie INTEGER, nombre_cientifico VARCHAR(120),
      nombre_comun VARCHAR(80), precio_unitario DECIMAL(10,2), descripcion VARCHAR(1000))
  AS
  BEGIN
    UPDATE especies SET nombre_cientifico = :nombre_cientifico, nombre_comun = :nombre_comun,
        precio_unitario = :precio_unitario, descripcion = :descripcion
      WHERE especies.id_especie = :id_especie;
  END

  PROCEDURE sp_especie_eliminar(id_especie INTEGER)
  AS
  BEGIN
    DELETE FROM especies WHERE especies.id_especie = :id_especie;
  END

  PROCEDURE sp_especie_listar_por_zona(id_zona INTEGER)
    RETURNS (id_especie INTEGER, nombre_comun VARCHAR(80), nombre_cientifico VARCHAR(120),
      precio_unitario DECIMAL(10,2), zona VARCHAR(80))
  AS
  BEGIN
    FOR SELECT v.id_especie, v.nombre_comun, v.nombre_cientifico, v.precio_unitario, v.zona
        FROM v_especies_por_zona v
        WHERE :id_zona IS NULL OR v.id_zona = :id_zona
        ORDER BY v.nombre_comun
        AS CURSOR c_especies
    DO
    BEGIN
      id_especie = c_especies.id_especie;
      nombre_comun = c_especies.nombre_comun;
      nombre_cientifico = c_especies.nombre_cientifico;
      precio_unitario = c_especies.precio_unitario;
      zona = c_especies.zona;
      SUSPEND;
    END
  END

  FUNCTION fn_especie_precio(id_especie INTEGER) RETURNS DECIMAL(10,2)
  AS
    DECLARE VARIABLE v_precio DECIMAL(10,2);
  BEGIN
    SELECT precio_unitario FROM especies WHERE especies.id_especie = :id_especie INTO :v_precio;
    RETURN v_precio;
  END

  FUNCTION fn_especie_existe(id_especie INTEGER) RETURNS BOOLEAN
  AS
  BEGIN
    RETURN EXISTS(SELECT 1 FROM especies e WHERE e.id_especie = :id_especie);
  END
END^

SET TERM ; ^

COMMIT;
