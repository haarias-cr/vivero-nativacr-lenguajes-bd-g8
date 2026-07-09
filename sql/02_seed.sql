-- Datos de prueba - Firebird
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 02_seed.sql

INSERT INTO zonas_biologicas (nombre, descripcion) VALUES
  ('Bosque seco tropical', 'Guanacaste y zonas bajas del Pacifico norte');
INSERT INTO zonas_biologicas (nombre, descripcion) VALUES
  ('Bosque lluvioso', 'Vertiente Caribe y zonas humedas');
INSERT INTO zonas_biologicas (nombre, descripcion) VALUES
  ('Paramo', 'Zonas altas de Cerro de la Muerte y Chirripo');

INSERT INTO especies (id_zona, nombre_cientifico, nombre_comun, precio_unitario, descripcion) VALUES
  (1, 'Enterolobium cyclocarpum', 'Guanacaste', 4500.00, 'Arbol emblematico de Guanacaste');
INSERT INTO especies (id_zona, nombre_cientifico, nombre_comun, precio_unitario, descripcion) VALUES
  (2, 'Swietenia macrophylla', 'Caoba', 7800.00, 'Especie maderable nativa');
INSERT INTO especies (id_zona, nombre_cientifico, nombre_comun, precio_unitario, descripcion) VALUES
  (2, 'Quercus copeyensis', 'Roble de altura', 6200.00, 'Roble de montana');
INSERT INTO especies (id_zona, nombre_cientifico, nombre_comun, precio_unitario, descripcion) VALUES
  (3, 'Chusquea phyllostachys', 'Bambu nativo', 3200.00, 'Bambu para cercas vivas');

INSERT INTO invernaderos (nombre, ubicacion, capacidad) VALUES
  ('Invernadero Norte', 'Sector A - Heredia', 500);
INSERT INTO invernaderos (nombre, ubicacion, capacidad) VALUES
  ('Invernadero Sur', 'Sector B - Cartago', 350);

INSERT INTO lotes (id_especie, id_invernadero, cantidad, fecha_siembra, estado) VALUES
  (1, 1, 120, '2026-03-15', 'activo');
INSERT INTO lotes (id_especie, id_invernadero, cantidad, fecha_siembra, estado) VALUES
  (2, 1, 80, '2026-04-01', 'activo');
INSERT INTO lotes (id_especie, id_invernadero, cantidad, fecha_siembra, estado) VALUES
  (3, 2, 60, '2026-04-20', 'activo');
INSERT INTO lotes (id_especie, id_invernadero, cantidad, fecha_siembra, estado) VALUES
  (4, 2, 200, '2026-05-10', 'activo');

INSERT INTO clientes (nombre, telefono, correo, tipo) VALUES
  ('Municipalidad de Heredia', '2260-0000', 'ambiente@heredia.go.cr', 'institucion');
INSERT INTO clientes (nombre, telefono, correo, tipo) VALUES
  ('Colegio Tecnico Ambiental', '2440-1234', 'contacto@ctambiental.ed.cr', 'institucion');
INSERT INTO clientes (nombre, telefono, correo, tipo) VALUES
  ('Maria Solis Rojas', '8888-1111', 'maria.solis@email.com', 'persona');

INSERT INTO pedidos (id_cliente, fecha_pedido, estado, total) VALUES
  (1, '2026-05-20 09:30:00', 'confirmado', 90000.00);
INSERT INTO pedidos (id_cliente, fecha_pedido, estado, total) VALUES
  (3, '2026-06-01 14:15:00', 'pendiente', 15600.00);

INSERT INTO detalle_pedido (id_pedido, id_lote, cantidad, subtotal) VALUES
  (1, 1, 20, 90000.00);
INSERT INTO detalle_pedido (id_pedido, id_lote, cantidad, subtotal) VALUES
  (2, 4, 3, 9600.00);

UPDATE pedidos SET total = 9600.00 WHERE id_pedido = 2;

INSERT INTO cuidados_lote (id_lote, fecha_cuidado, tipo_cuidado, observaciones) VALUES
  (1, '2026-06-05', 'riego', 'Riego matutino - 15 min');
INSERT INTO cuidados_lote (id_lote, fecha_cuidado, tipo_cuidado, observaciones) VALUES
  (1, '2026-06-08', 'fertilizacion', 'Abono organico NPK bajo');
INSERT INTO cuidados_lote (id_lote, fecha_cuidado, tipo_cuidado, observaciones) VALUES
  (3, '2026-06-07', 'control_plagas', 'Revision de pulgon en hojas nuevas');

COMMIT;
