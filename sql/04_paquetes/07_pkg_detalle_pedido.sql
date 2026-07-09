-- Paquete 7/10: detalle_pedido
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 07_pkg_detalle_pedido.sql

CREATE EXCEPTION ex_stock_insuficiente 'No hay suficiente cantidad disponible en el lote solicitado.';

SET TERM ^ ;

CREATE PACKAGE pkg_detalle_pedido
SQL SECURITY DEFINER
AS
BEGIN
  PROCEDURE sp_detalle_insertar(id_pedido INTEGER, id_lote INTEGER, cantidad INTEGER)
    RETURNS (id_detalle INTEGER);
  PROCEDURE sp_detalle_actualizar(id_detalle INTEGER, cantidad INTEGER);
  PROCEDURE sp_detalle_eliminar(id_detalle INTEGER);
  PROCEDURE sp_detalle_listar_por_pedido(id_pedido INTEGER)
    RETURNS (id_detalle INTEGER, especie VARCHAR(80), cantidad INTEGER, subtotal DECIMAL(12,2));

  FUNCTION fn_detalle_subtotal(id_detalle INTEGER) RETURNS DECIMAL(12,2);
END^

CREATE PACKAGE BODY pkg_detalle_pedido
AS
BEGIN
  PROCEDURE sp_detalle_insertar(id_pedido INTEGER, id_lote INTEGER, cantidad INTEGER)
    RETURNS (id_detalle INTEGER)
  AS
    DECLARE VARIABLE v_precio DECIMAL(10,2);
    DECLARE VARIABLE v_stock INTEGER;
    DECLARE VARIABLE v_subtotal DECIMAL(12,2);
  BEGIN
    SELECT l.cantidad, e.precio_unitario
      FROM lotes l JOIN especies e ON e.id_especie = l.id_especie
      WHERE l.id_lote = :id_lote
      INTO :v_stock, :v_precio;

    IF (v_stock IS NULL OR v_stock < cantidad) THEN
      EXCEPTION ex_stock_insuficiente;

    v_subtotal = v_precio * cantidad;

    INSERT INTO detalle_pedido (id_pedido, id_lote, cantidad, subtotal)
      VALUES (:id_pedido, :id_lote, :cantidad, :v_subtotal)
      RETURNING detalle_pedido.id_detalle INTO :id_detalle;
  END

  PROCEDURE sp_detalle_actualizar(id_detalle INTEGER, cantidad INTEGER)
  AS
    DECLARE VARIABLE v_id_pedido INTEGER;
    DECLARE VARIABLE v_id_lote INTEGER;
    DECLARE VARIABLE v_nuevo_id INTEGER;
  BEGIN
    SELECT id_pedido, id_lote FROM detalle_pedido
      WHERE detalle_pedido.id_detalle = :id_detalle
      INTO :v_id_pedido, :v_id_lote;

    -- Se elimina y se vuelve a insertar para reutilizar los triggers de
    -- reposicion de stock y recalculo de total sin duplicar esa logica aqui.
    DELETE FROM detalle_pedido WHERE detalle_pedido.id_detalle = :id_detalle;

    EXECUTE PROCEDURE sp_detalle_insertar(:v_id_pedido, :v_id_lote, :cantidad)
      RETURNING_VALUES :v_nuevo_id;
  END

  PROCEDURE sp_detalle_eliminar(id_detalle INTEGER)
  AS
  BEGIN
    DELETE FROM detalle_pedido WHERE detalle_pedido.id_detalle = :id_detalle;
  END

  PROCEDURE sp_detalle_listar_por_pedido(id_pedido INTEGER)
    RETURNS (id_detalle INTEGER, especie VARCHAR(80), cantidad INTEGER, subtotal DECIMAL(12,2))
  AS
  BEGIN
    FOR SELECT d.id_detalle, e.nombre_comun, d.cantidad, d.subtotal
        FROM detalle_pedido d
        JOIN lotes l ON l.id_lote = d.id_lote
        JOIN especies e ON e.id_especie = l.id_especie
        WHERE d.id_pedido = :id_pedido
        AS CURSOR c_detalle
    DO
    BEGIN
      id_detalle = c_detalle.id_detalle;
      especie = c_detalle.nombre_comun;
      cantidad = c_detalle.cantidad;
      subtotal = c_detalle.subtotal;
      SUSPEND;
    END
  END

  FUNCTION fn_detalle_subtotal(id_detalle INTEGER) RETURNS DECIMAL(12,2)
  AS
    DECLARE VARIABLE v_subtotal DECIMAL(12,2);
  BEGIN
    SELECT subtotal FROM detalle_pedido WHERE detalle_pedido.id_detalle = :id_detalle
      INTO :v_subtotal;
    RETURN v_subtotal;
  END
END^

SET TERM ; ^

COMMIT;
