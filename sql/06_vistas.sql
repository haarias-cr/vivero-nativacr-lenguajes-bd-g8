-- Vivero NativaCR - Grupo 8
-- Vistas (10) - Firebird
-- Sirven de base para el diccionario de datos y para los procedimientos
-- selectables de sql/04_paquetes/. La aplicacion Python nunca las consulta
-- directamente: siempre pasa por un procedimiento almacenado.
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 06_vistas.sql

CREATE VIEW v_inventario_activo AS
SELECT l.id_lote,
       e.nombre_comun,
       e.nombre_cientifico,
       i.nombre AS invernadero,
       l.cantidad,
       l.fecha_siembra,
       l.estado
FROM lotes l
JOIN especies e ON e.id_especie = l.id_especie
JOIN invernaderos i ON i.id_invernadero = l.id_invernadero
WHERE l.estado = 'activo';

CREATE VIEW v_especies_por_zona AS
SELECT z.id_zona,
       z.nombre AS zona,
       e.id_especie,
       e.nombre_comun,
       e.nombre_cientifico,
       e.precio_unitario
FROM especies e
JOIN zonas_biologicas z ON z.id_zona = e.id_zona;

CREATE VIEW v_pedidos_detalle AS
SELECT p.id_pedido,
       c.nombre AS cliente,
       p.fecha_pedido,
       p.estado,
       e.nombre_comun AS especie,
       d.cantidad,
       d.subtotal
FROM pedidos p
JOIN clientes c ON c.id_cliente = p.id_cliente
JOIN detalle_pedido d ON d.id_pedido = p.id_pedido
JOIN lotes l ON l.id_lote = d.id_lote
JOIN especies e ON e.id_especie = l.id_especie;

CREATE VIEW v_ventas_por_zona AS
SELECT z.id_zona,
       z.nombre AS zona,
       COUNT(DISTINCT e.id_especie) AS especies_distintas,
       SUM(d.cantidad) AS plantas_vendidas,
       SUM(d.subtotal) AS monto_total
FROM detalle_pedido d
JOIN lotes l ON l.id_lote = d.id_lote
JOIN especies e ON e.id_especie = l.id_especie
JOIN zonas_biologicas z ON z.id_zona = e.id_zona
GROUP BY z.id_zona, z.nombre;

CREATE VIEW v_invernaderos_ocupacion AS
SELECT i.id_invernadero,
       i.nombre,
       i.capacidad,
       COALESCE(SUM(l.cantidad), 0) AS plantas_actuales,
       i.capacidad - COALESCE(SUM(l.cantidad), 0) AS espacio_disponible
FROM invernaderos i
LEFT JOIN lotes l ON l.id_invernadero = i.id_invernadero AND l.estado = 'activo'
GROUP BY i.id_invernadero, i.nombre, i.capacidad;

CREATE VIEW v_lotes_stock_bajo AS
SELECT l.id_lote,
       e.nombre_comun,
       i.nombre AS invernadero,
       l.cantidad,
       l.estado
FROM lotes l
JOIN especies e ON e.id_especie = l.id_especie
JOIN invernaderos i ON i.id_invernadero = l.id_invernadero
WHERE l.estado = 'activo' AND l.cantidad < 20;

CREATE VIEW v_cuidados_recientes AS
SELECT cd.id_cuidado,
       cd.fecha_cuidado,
       cd.tipo_cuidado,
       cd.observaciones,
       e.nombre_comun,
       l.id_lote
FROM cuidados_lote cd
JOIN lotes l ON l.id_lote = cd.id_lote
JOIN especies e ON e.id_especie = l.id_especie;

CREATE VIEW v_pedidos_pendientes AS
SELECT p.id_pedido,
       c.nombre AS cliente,
       p.fecha_pedido,
       p.total
FROM pedidos p
JOIN clientes c ON c.id_cliente = p.id_cliente
WHERE p.estado = 'pendiente';

CREATE VIEW v_clientes_resumen AS
SELECT c.id_cliente,
       c.nombre,
       c.tipo,
       COUNT(p.id_pedido) AS total_pedidos,
       COALESCE(SUM(p.total), 0) AS monto_acumulado
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.tipo;

CREATE VIEW v_catalogo_especies AS
SELECT e.id_especie,
       e.nombre_comun,
       e.nombre_cientifico,
       e.precio_unitario,
       z.nombre AS zona,
       e.descripcion
FROM especies e
JOIN zonas_biologicas z ON z.id_zona = e.id_zona;

COMMIT;
