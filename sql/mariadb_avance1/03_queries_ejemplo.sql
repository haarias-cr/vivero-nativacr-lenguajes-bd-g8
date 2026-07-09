-- Consultas de ejemplo

USE vivero_nativacr;

-- Inventario activo por especie e invernadero
SELECT e.nombre_comun,
       e.nombre_cientifico,
       i.nombre AS invernadero,
       l.cantidad,
       l.fecha_siembra,
       l.estado
FROM lotes l
JOIN especies e ON e.id_especie = l.id_especie
JOIN invernaderos i ON i.id_invernadero = l.id_invernadero
WHERE l.estado = 'activo'
ORDER BY e.nombre_comun;

-- Pedidos con detalle (JOIN)
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
JOIN especies e ON e.id_especie = l.id_especie
ORDER BY p.fecha_pedido DESC;

-- Total vendido por zona biológica (agrupamiento)
SELECT z.nombre AS zona,
       COUNT(DISTINCT e.id_especie) AS especies_distintas,
       SUM(d.cantidad) AS plantas_vendidas,
       SUM(d.subtotal) AS monto_total
FROM detalle_pedido d
JOIN lotes l ON l.id_lote = d.id_lote
JOIN especies e ON e.id_especie = l.id_especie
JOIN zonas_biologicas z ON z.id_zona = e.id_zona
GROUP BY z.id_zona, z.nombre;
