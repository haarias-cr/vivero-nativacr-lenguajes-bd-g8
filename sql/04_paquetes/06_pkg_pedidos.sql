-- Paquete 6/10: pedidos
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 06_pkg_pedidos.sql

CREATE EXCEPTION ex_pedido_sin_detalle 'No se puede confirmar un pedido sin lineas de detalle.';

SET TERM ^ ;

CREATE PACKAGE pkg_pedidos
SQL SECURITY DEFINER
AS
BEGIN
  PROCEDURE sp_pedido_insertar(id_cliente INTEGER)
    RETURNS (id_pedido INTEGER);
  PROCEDURE sp_pedido_eliminar(id_pedido INTEGER);
  PROCEDURE sp_pedido_confirmar(id_pedido INTEGER);
  PROCEDURE sp_pedido_marcar_entregado(id_pedido INTEGER);
  PROCEDURE sp_pedido_cancelar(id_pedido INTEGER);
  PROCEDURE sp_pedido_listar
    RETURNS (id_pedido INTEGER, cliente VARCHAR(100), fecha_pedido TIMESTAMP,
      estado VARCHAR(12), total DECIMAL(12,2));

  FUNCTION fn_pedido_total(id_pedido INTEGER) RETURNS DECIMAL(12,2);
  FUNCTION fn_pedido_puede_cancelar(id_pedido INTEGER) RETURNS BOOLEAN;
END^

CREATE PACKAGE BODY pkg_pedidos
AS
BEGIN
  PROCEDURE sp_pedido_insertar(id_cliente INTEGER)
    RETURNS (id_pedido INTEGER)
  AS
  BEGIN
    INSERT INTO pedidos (id_cliente, estado, total)
      VALUES (:id_cliente, 'pendiente', 0)
      RETURNING pedidos.id_pedido INTO :id_pedido;
  END

  PROCEDURE sp_pedido_eliminar(id_pedido INTEGER)
  AS
  BEGIN
    DELETE FROM detalle_pedido WHERE detalle_pedido.id_pedido = :id_pedido;
    DELETE FROM pedidos WHERE pedidos.id_pedido = :id_pedido;
  END

  PROCEDURE sp_pedido_confirmar(id_pedido INTEGER)
  AS
    DECLARE VARIABLE v_lineas INTEGER;
  BEGIN
    SELECT COUNT(*) FROM detalle_pedido WHERE detalle_pedido.id_pedido = :id_pedido
      INTO :v_lineas;

    IF (v_lineas = 0) THEN
      EXCEPTION ex_pedido_sin_detalle;

    UPDATE pedidos SET estado = 'confirmado' WHERE pedidos.id_pedido = :id_pedido;
  END

  PROCEDURE sp_pedido_marcar_entregado(id_pedido INTEGER)
  AS
  BEGIN
    UPDATE pedidos SET estado = 'entregado'
      WHERE pedidos.id_pedido = :id_pedido AND pedidos.estado = 'confirmado';
  END

  PROCEDURE sp_pedido_cancelar(id_pedido INTEGER)
  AS
    DECLARE VARIABLE v_id_detalle INTEGER;
  BEGIN
    FOR SELECT d.id_detalle FROM detalle_pedido d
        WHERE d.id_pedido = :id_pedido
        AS CURSOR c_detalle
    DO
    BEGIN
      v_id_detalle = c_detalle.id_detalle;
      DELETE FROM detalle_pedido WHERE detalle_pedido.id_detalle = :v_id_detalle;
    END

    UPDATE pedidos SET estado = 'cancelado' WHERE pedidos.id_pedido = :id_pedido;
  END

  PROCEDURE sp_pedido_listar
    RETURNS (id_pedido INTEGER, cliente VARCHAR(100), fecha_pedido TIMESTAMP,
      estado VARCHAR(12), total DECIMAL(12,2))
  AS
  BEGIN
    FOR SELECT p.id_pedido, c.nombre, p.fecha_pedido, p.estado, p.total
        FROM pedidos p
        JOIN clientes c ON c.id_cliente = p.id_cliente
        ORDER BY p.fecha_pedido DESC
        AS CURSOR c_pedidos
    DO
    BEGIN
      id_pedido = c_pedidos.id_pedido;
      cliente = c_pedidos.nombre;
      fecha_pedido = c_pedidos.fecha_pedido;
      estado = c_pedidos.estado;
      total = c_pedidos.total;
      SUSPEND;
    END
  END

  FUNCTION fn_pedido_total(id_pedido INTEGER) RETURNS DECIMAL(12,2)
  AS
    DECLARE VARIABLE v_total DECIMAL(12,2);
    DECLARE VARIABLE v_subtotal DECIMAL(12,2);
  BEGIN
    v_total = 0;
    FOR SELECT d.subtotal FROM detalle_pedido d
        WHERE d.id_pedido = :id_pedido
        AS CURSOR c_detalle
    DO
    BEGIN
      v_subtotal = c_detalle.subtotal;
      v_total = v_total + v_subtotal;
    END
    RETURN v_total;
  END

  FUNCTION fn_pedido_puede_cancelar(id_pedido INTEGER) RETURNS BOOLEAN
  AS
  BEGIN
    RETURN EXISTS(
      SELECT 1 FROM pedidos p
      WHERE p.id_pedido = :id_pedido AND p.estado NOT IN ('entregado', 'cancelado'));
  END
END^

SET TERM ; ^

COMMIT;
