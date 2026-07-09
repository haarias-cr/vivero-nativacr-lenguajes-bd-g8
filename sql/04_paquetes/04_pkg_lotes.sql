-- Paquete 4/10: lotes
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 04_pkg_lotes.sql

SET TERM ^ ;

CREATE PACKAGE pkg_lotes
SQL SECURITY DEFINER
AS
BEGIN
  PROCEDURE sp_lote_insertar(id_especie INTEGER, id_invernadero INTEGER, cantidad INTEGER,
      fecha_siembra DATE)
    RETURNS (id_lote INTEGER);
  PROCEDURE sp_lote_actualizar(id_lote INTEGER, cantidad INTEGER, estado VARCHAR(12));
  PROCEDURE sp_lote_eliminar(id_lote INTEGER);
  PROCEDURE sp_lote_listar_activos
    RETURNS (id_lote INTEGER, nombre_comun VARCHAR(80), nombre_cientifico VARCHAR(120),
      invernadero VARCHAR(60), cantidad INTEGER, fecha_siembra DATE, estado VARCHAR(12));

  FUNCTION fn_lote_edad_dias(id_lote INTEGER) RETURNS INTEGER;
  FUNCTION fn_lote_disponible(id_lote INTEGER) RETURNS BOOLEAN;
END^

CREATE PACKAGE BODY pkg_lotes
AS
BEGIN
  PROCEDURE sp_lote_insertar(id_especie INTEGER, id_invernadero INTEGER, cantidad INTEGER,
      fecha_siembra DATE)
    RETURNS (id_lote INTEGER)
  AS
  BEGIN
    INSERT INTO lotes (id_especie, id_invernadero, cantidad, fecha_siembra, estado)
      VALUES (:id_especie, :id_invernadero, :cantidad, :fecha_siembra, 'activo')
      RETURNING lotes.id_lote INTO :id_lote;
  END

  PROCEDURE sp_lote_actualizar(id_lote INTEGER, cantidad INTEGER, estado VARCHAR(12))
  AS
  BEGIN
    UPDATE lotes SET cantidad = :cantidad, estado = :estado
      WHERE lotes.id_lote = :id_lote;
  END

  PROCEDURE sp_lote_eliminar(id_lote INTEGER)
  AS
  BEGIN
    DELETE FROM lotes WHERE lotes.id_lote = :id_lote;
  END

  PROCEDURE sp_lote_listar_activos
    RETURNS (id_lote INTEGER, nombre_comun VARCHAR(80), nombre_cientifico VARCHAR(120),
      invernadero VARCHAR(60), cantidad INTEGER, fecha_siembra DATE, estado VARCHAR(12))
  AS
  BEGIN
    FOR SELECT v.id_lote, v.nombre_comun, v.nombre_cientifico, v.invernadero, v.cantidad,
               v.fecha_siembra, v.estado
        FROM v_inventario_activo v
        ORDER BY v.nombre_comun
        AS CURSOR c_lotes
    DO
    BEGIN
      id_lote = c_lotes.id_lote;
      nombre_comun = c_lotes.nombre_comun;
      nombre_cientifico = c_lotes.nombre_cientifico;
      invernadero = c_lotes.invernadero;
      cantidad = c_lotes.cantidad;
      fecha_siembra = c_lotes.fecha_siembra;
      estado = c_lotes.estado;
      SUSPEND;
    END
  END

  FUNCTION fn_lote_edad_dias(id_lote INTEGER) RETURNS INTEGER
  AS
    DECLARE VARIABLE v_fecha DATE;
  BEGIN
    SELECT fecha_siembra FROM lotes WHERE lotes.id_lote = :id_lote INTO :v_fecha;
    RETURN CURRENT_DATE - v_fecha;
  END

  FUNCTION fn_lote_disponible(id_lote INTEGER) RETURNS BOOLEAN
  AS
  BEGIN
    RETURN EXISTS(
      SELECT 1 FROM lotes l
      WHERE l.id_lote = :id_lote AND l.estado = 'activo' AND l.cantidad > 0);
  END
END^

SET TERM ; ^

COMMIT;
