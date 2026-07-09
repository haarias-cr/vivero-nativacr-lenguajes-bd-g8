# Scripts SQL (Firebird - Avance II)

Base de datos: `vivero_nativacr.fdb`. Ver [docs/migracion-firebird.md](../docs/migracion-firebird.md)
para el porqué del cambio de motor desde MariaDB (Avance I, conservado en
`mariadb_avance1/`).

| Archivo | Descripción |
|---------|-------------|
| `01_schema.sql` | Crea la base de datos y las 8 tablas |
| `02_seed.sql` | Datos de prueba |
| `03_usuario_app.sql` | Usuario de aplicación (`vivero_app`) |
| `04_paquetes/` | Los 10 paquetes (procedimientos, funciones, cursores) |
| `05_diccionario_datos.sql` | Consulta de diccionario de datos (catálogos del sistema) |
| `06_vistas.sql` | Las 10 vistas |
| `07_triggers.sql` | Los 5 triggers |
| `08_permisos_app.sql` | Otorga `EXECUTE` sobre los paquetes a `vivero_app` (sin acceso directo a tablas) |

Ejecutar en el orden indicado (ver instrucciones completas en el `README.md`
raíz del repositorio).
