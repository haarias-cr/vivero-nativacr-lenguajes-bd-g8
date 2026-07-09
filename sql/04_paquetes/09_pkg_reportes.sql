-- Paquete 9/10: reportes (procedimientos selectables sobre las vistas analiticas)
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 09_pkg_reportes.sql

SET TERM ^ ;

CREATE PACKAGE pkg_reportes
SQL SECURITY DEFINER
AS
BEGIN
  PROCEDURE sp_reporte_inventario_activo
    RETURNS (id_lote INTEGER, nombre_comun VARCHAR(80), nombre_cientifico VARCHAR(120),
      invernadero VARCHAR(60), cantidad INTEGER, fecha_siembra DATE, estado VARCHAR(12));
  PROCEDURE sp_reporte_ventas_zona
    RETURNS (zona VARCHAR(80), especies_distintas INTEGER, plantas_vendidas INTEGER,
      monto_total DECIMAL(12,2));
  PROCEDURE sp_reporte_pedidos_detalle
    RETURNS (id_pedido INTEGER, cliente VARCHAR(100), fecha_pedido TIMESTAMP, estado VARCHAR(12),
      especie VARCHAR(80), cantidad INTEGER, subtotal DECIMAL(12,2));
  PROCEDURE sp_reporte_ocupacion_invernaderos
    RETURNS (id_invernadero INTEGER, nombre VARCHAR(60), capacidad INTEGER,
      plantas_actuales INTEGER, espacio_disponible INTEGER);

  FUNCTION fn_ventas_totales_zona(id_zona INTEGER) RETURNS DECIMAL(12,2);
  FUNCTION fn_plantas_vendidas_zona(id_zona INTEGER) RETURNS INTEGER;
END^

CREATE PACKAGE BODY pkg_reportes
AS
BEGIN
  PROCEDURE sp_reporte_inventario_activo
    RETURNS (id_lote INTEGER, nombre_comun VARCHAR(80), nombre_cientifico VARCHAR(120),
      invernadero VARCHAR(60), cantidad INTEGER, fecha_siembra DATE, estado VARCHAR(12))
  AS
  BEGIN
    FOR SELECT v.id_lote, v.nombre_comun, v.nombre_cientifico, v.invernadero, v.cantidad,
               v.fecha_siembra, v.estado
        FROM v_inventario_activo v
        AS CURSOR c_rep
    DO
    BEGIN
      id_lote = c_rep.id_lote;
      nombre_comun = c_rep.nombre_comun;
      nombre_cientifico = c_rep.nombre_cientifico;
      invernadero = c_rep.invernadero;
      cantidad = c_rep.cantidad;
      fecha_siembra = c_rep.fecha_siembra;
      estado = c_rep.estado;
      SUSPEND;
    END
  END

  PROCEDURE sp_reporte_ventas_zona
    RETURNS (zona VARCHAR(80), especies_distintas INTEGER, plantas_vendidas INTEGER,
      monto_total DECIMAL(12,2))
  AS
  BEGIN
    FOR SELECT v.zona, v.especies_distintas, v.plantas_vendidas, v.monto_total
        FROM v_ventas_por_zona v
        AS CURSOR c_rep
    DO
    BEGIN
      zona = c_rep.zona;
      especies_distintas = c_rep.especies_distintas;
      plantas_vendidas = c_rep.plantas_vendidas;
      monto_total = c_rep.monto_total;
      SUSPEND;
    END
  END

  PROCEDURE sp_reporte_pedidos_detalle
    RETURNS (id_pedido INTEGER, cliente VARCHAR(100), fecha_pedido TIMESTAMP, estado VARCHAR(12),
      especie VARCHAR(80), cantidad INTEGER, subtotal DECIMAL(12,2))
  AS
  BEGIN
    FOR SELECT v.id_pedido, v.cliente, v.fecha_pedido, v.estado, v.especie, v.cantidad, v.subtotal
        FROM v_pedidos_detalle v
        AS CURSOR c_rep
    DO
    BEGIN
      id_pedido = c_rep.id_pedido;
      cliente = c_rep.cliente;
      fecha_pedido = c_rep.fecha_pedido;
      estado = c_rep.estado;
      especie = c_rep.especie;
      cantidad = c_rep.cantidad;
      subtotal = c_rep.subtotal;
      SUSPEND;
    END
  END

  PROCEDURE sp_reporte_ocupacion_invernaderos
    RETURNS (id_invernadero INTEGER, nombre VARCHAR(60), capacidad INTEGER,
      plantas_actuales INTEGER, espacio_disponible INTEGER)
  AS
  BEGIN
    FOR SELECT v.id_invernadero, v.nombre, v.capacidad, v.plantas_actuales, v.espacio_disponible
        FROM v_invernaderos_ocupacion v
        AS CURSOR c_rep
    DO
    BEGIN
      id_invernadero = c_rep.id_invernadero;
      nombre = c_rep.nombre;
      capacidad = c_rep.capacidad;
      plantas_actuales = c_rep.plantas_actuales;
      espacio_disponible = c_rep.espacio_disponible;
      SUSPEND;
    END
  END

  FUNCTION fn_ventas_totales_zona(id_zona INTEGER) RETURNS DECIMAL(12,2)
  AS
    DECLARE VARIABLE v_total DECIMAL(12,2);
    DECLARE VARIABLE v_subtotal DECIMAL(12,2);
  BEGIN
    v_total = 0;
    FOR SELECT d.subtotal
        FROM detalle_pedido d
        JOIN lotes l ON l.id_lote = d.id_lote
        JOIN especies e ON e.id_especie = l.id_especie
        WHERE e.id_zona = :id_zona
        AS CURSOR c_ventas
    DO
    BEGIN
      v_subtotal = c_ventas.subtotal;
      v_total = v_total + v_subtotal;
    END
    RETURN v_total;
  END

  FUNCTION fn_plantas_vendidas_zona(id_zona INTEGER) RETURNS INTEGER
  AS
    DECLARE VARIABLE v_total INTEGER;
    DECLARE VARIABLE v_cantidad INTEGER;
  BEGIN
    v_total = 0;
    FOR SELECT d.cantidad
        FROM detalle_pedido d
        JOIN lotes l ON l.id_lote = d.id_lote
        JOIN especies e ON e.id_especie = l.id_especie
        WHERE e.id_zona = :id_zona
        AS CURSOR c_plantas
    DO
    BEGIN
      v_cantidad = c_plantas.cantidad;
      v_total = v_total + v_cantidad;
    END
    RETURN v_total;
  END
END^

SET TERM ; ^

COMMIT;
