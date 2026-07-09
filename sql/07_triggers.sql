-- Vivero NativaCR - Grupo 8
-- Triggers (5) - Firebird
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 07_triggers.sql

CREATE EXCEPTION ex_lote_descartado 'No se puede registrar un cuidado sobre un lote descartado.';

SET TERM ^ ;

-- Al insertar una linea de pedido: descuenta el stock del lote y recalcula el total del pedido
CREATE TRIGGER trg_detalle_pedido_ai FOR detalle_pedido
ACTIVE AFTER INSERT POSITION 0
AS
BEGIN
  UPDATE lotes SET cantidad = cantidad - NEW.cantidad WHERE id_lote = NEW.id_lote;

  UPDATE pedidos SET total = (SELECT SUM(subtotal) FROM detalle_pedido WHERE id_pedido = NEW.id_pedido)
  WHERE id_pedido = NEW.id_pedido;
END^

-- Al eliminar una linea de pedido: devuelve el stock del lote y recalcula el total del pedido
CREATE TRIGGER trg_detalle_pedido_ad FOR detalle_pedido
ACTIVE AFTER DELETE POSITION 0
AS
BEGIN
  UPDATE lotes SET cantidad = cantidad + OLD.cantidad WHERE id_lote = OLD.id_lote;

  UPDATE pedidos SET total = COALESCE(
    (SELECT SUM(subtotal) FROM detalle_pedido WHERE id_pedido = OLD.id_pedido), 0)
  WHERE id_pedido = OLD.id_pedido;
END^

-- Marca automaticamente un lote como 'vendido' cuando su cantidad llega a 0
CREATE TRIGGER trg_lotes_bu FOR lotes
ACTIVE BEFORE UPDATE POSITION 0
AS
BEGIN
  IF (NEW.cantidad = 0 AND NEW.estado = 'activo') THEN
    NEW.estado = 'vendido';
END^

-- Si no se indica descripcion de la especie, deja un texto por defecto en vez de NULL
CREATE TRIGGER trg_especies_bi FOR especies
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.descripcion IS NULL) THEN
    NEW.descripcion = 'Sin descripcion registrada';
END^

-- Impide registrar cuidados sobre lotes ya descartados
CREATE TRIGGER trg_cuidados_lote_bi FOR cuidados_lote
ACTIVE BEFORE INSERT POSITION 0
AS
DECLARE VARIABLE v_estado VARCHAR(12);
BEGIN
  SELECT estado FROM lotes WHERE id_lote = NEW.id_lote INTO :v_estado;

  IF (v_estado = 'descartado') THEN
    EXCEPTION ex_lote_descartado;
END^

SET TERM ; ^

COMMIT;
