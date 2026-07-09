-- Paquete 8/10: cuidados_lote
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 08_pkg_cuidados_lote.sql

SET TERM ^ ;

CREATE PACKAGE pkg_cuidados_lote
SQL SECURITY DEFINER
AS
BEGIN
  PROCEDURE sp_cuidado_insertar(id_lote INTEGER, tipo_cuidado VARCHAR(20), observaciones VARCHAR(255))
    RETURNS (id_cuidado INTEGER);
  PROCEDURE sp_cuidado_actualizar(id_cuidado INTEGER, observaciones VARCHAR(255));
  PROCEDURE sp_cuidado_eliminar(id_cuidado INTEGER);
  PROCEDURE sp_cuidado_listar_por_lote(id_lote INTEGER)
    RETURNS (id_cuidado INTEGER, fecha_cuidado DATE, tipo_cuidado VARCHAR(20),
      observaciones VARCHAR(255));

  FUNCTION fn_cuidado_dias_desde_ultimo(id_lote INTEGER) RETURNS INTEGER;
END^

CREATE PACKAGE BODY pkg_cuidados_lote
AS
BEGIN
  PROCEDURE sp_cuidado_insertar(id_lote INTEGER, tipo_cuidado VARCHAR(20), observaciones VARCHAR(255))
    RETURNS (id_cuidado INTEGER)
  AS
  BEGIN
    INSERT INTO cuidados_lote (id_lote, fecha_cuidado, tipo_cuidado, observaciones)
      VALUES (:id_lote, CURRENT_DATE, :tipo_cuidado, :observaciones)
      RETURNING cuidados_lote.id_cuidado INTO :id_cuidado;
  END

  PROCEDURE sp_cuidado_actualizar(id_cuidado INTEGER, observaciones VARCHAR(255))
  AS
  BEGIN
    UPDATE cuidados_lote SET observaciones = :observaciones
      WHERE cuidados_lote.id_cuidado = :id_cuidado;
  END

  PROCEDURE sp_cuidado_eliminar(id_cuidado INTEGER)
  AS
  BEGIN
    DELETE FROM cuidados_lote WHERE cuidados_lote.id_cuidado = :id_cuidado;
  END

  PROCEDURE sp_cuidado_listar_por_lote(id_lote INTEGER)
    RETURNS (id_cuidado INTEGER, fecha_cuidado DATE, tipo_cuidado VARCHAR(20),
      observaciones VARCHAR(255))
  AS
  BEGIN
    FOR SELECT cd.id_cuidado, cd.fecha_cuidado, cd.tipo_cuidado, cd.observaciones
        FROM cuidados_lote cd
        WHERE cd.id_lote = :id_lote
        ORDER BY cd.fecha_cuidado DESC
        AS CURSOR c_cuidados
    DO
    BEGIN
      id_cuidado = c_cuidados.id_cuidado;
      fecha_cuidado = c_cuidados.fecha_cuidado;
      tipo_cuidado = c_cuidados.tipo_cuidado;
      observaciones = c_cuidados.observaciones;
      SUSPEND;
    END
  END

  FUNCTION fn_cuidado_dias_desde_ultimo(id_lote INTEGER) RETURNS INTEGER
  AS
    DECLARE VARIABLE v_ultima_fecha DATE;
    DECLARE VARIABLE v_fecha DATE;
  BEGIN
    v_ultima_fecha = NULL;

    FOR SELECT cd.fecha_cuidado FROM cuidados_lote cd
        WHERE cd.id_lote = :id_lote
        ORDER BY cd.fecha_cuidado DESC
        AS CURSOR c_fechas
    DO
    BEGIN
      v_fecha = c_fechas.fecha_cuidado;
      IF (v_ultima_fecha IS NULL) THEN
        v_ultima_fecha = v_fecha;
    END

    IF (v_ultima_fecha IS NULL) THEN
      RETURN NULL;

    RETURN CURRENT_DATE - v_ultima_fecha;
  END
END^

SET TERM ; ^

COMMIT;
