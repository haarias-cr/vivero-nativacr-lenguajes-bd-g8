# Cambio de motor de base de datos: MariaDB a Firebird

## Motivo

El instructivo del Avance II exige, entre los objetos programables mínimos,
**10 paquetes** (packages) de procedimientos y funciones. El paquete es un
concepto propio del lenguaje PL/SQL de Oracle, adoptado también por otros
motores como Firebird a través de la sentencia `CREATE PACKAGE`
(Firebird Project, 2023). **MariaDB no implementa paquetes**: su
documentación oficial de sentencias de programabilidad (procedimientos,
funciones, triggers, cursores) no incluye ningún objeto equivalente
(MariaDB Foundation, 2024). No existe forma de cumplir ese requisito
manteniendo MariaDB como motor sin recurrir a una simulación artificial
(por ejemplo, agrupar procedimientos únicamente por convención de nombres),
lo cual no constituye un paquete real desde el punto de vista del motor.

## Decisión

El grupo decidió migrar el motor de base de datos de MariaDB a **Firebird 4**
para el Avance II y el resto del proyecto. Firebird soporta paquetes de forma
nativa desde la versión 3.0 (`CREATE PACKAGE` / `CREATE PACKAGE BODY`), además
de procedimientos almacenados, funciones, vistas, triggers y cursores
explícitos (`DECLARE CURSOR`, `FOR SELECT ... AS CURSOR`), cubriendo todos
los objetos programables pedidos por el instructivo con implementaciones
reales y no simuladas.

El lenguaje de conexión definido en el Avance I (**Python 3**) no cambia. El
esquema de 8 tablas, los requerimientos funcionales y no funcionales, y los
datos de prueba del Avance I se migraron sin alterar su diseño ni su
propósito; solo cambió el dialecto SQL/DDL empleado para crearlos. Los
scripts originales de MariaDB del Avance I se conservan en
`sql/mariadb_avance1/` como evidencia histórica.

## Objetos construidos en el Avance II

- 10 paquetes (`sql/04_paquetes/`), uno por cada una de las 8 tablas del
  modelo más `pkg_reportes` y `pkg_utilidades`.
- 38 procedimientos almacenados (mínimo pedido: 25).
- 15 funciones.
- 10 vistas.
- 5 triggers.
- Cursores explícitos en los procedimientos y funciones de listado y
  reportes (mínimo pedido: 15).

Toda la aplicación Python (`src/vivero_app.py`) invoca exclusivamente estos
procedimientos: no contiene ninguna sentencia SQL directa contra tablas. El
usuario de aplicación `vivero_app` solo tiene permiso `EXECUTE` sobre los
paquetes (sin `SELECT`/`INSERT`/`UPDATE`/`DELETE` directo sobre tablas),
reforzando esa regla también a nivel del motor de base de datos.

## Referencias

Firebird Project. (2023). *Firebird 4.0 language reference: CREATE PACKAGE*.
https://www.firebirdsql.org/file/documentation/html/en/refdocs/fblangref40/firebird-40-language-reference.html

MariaDB Foundation. (2024). *MariaDB Server documentation: Programmable
objects (stored procedures and functions, triggers, cursors)*.
https://mariadb.com/kb/en/documentation/
