# Vivero NativaCR

Proyecto final de Lenguajes de Base de Datos (SC-504).
Universidad Fidelitas, Grupo 8.

Sistema para un vivero de plantas nativas: inventario, pedidos y cuidados por lote.

**Integrantes:** Natalia Aguero, Harvi Arias, Camilo Montero

## Contenido del repositorio

| Carpeta | Descripción |
|---------|-------------|
| `docs/` | Avance I, Avance II y documentación del proyecto |
| `sql/` | Scripts de la base de datos (Firebird, Avance II) |
| `sql/mariadb_avance1/` | Scripts originales del Avance I (MariaDB) |
| `src/` | Programa en Python 3 |

## Motor de base de datos

Desde el Avance II el proyecto usa **Firebird 4** (ver [docs/migracion-firebird.md](docs/migracion-firebird.md)
para la justificación del cambio desde MariaDB). El lenguaje de conexión sigue
siendo Python 3, tal como se definió en el Avance I.

## Instalación de la base de datos

Requiere Firebird 4 (`dnf install firebird firebird-utils` en RHEL/CentOS,
vía el repositorio EPEL). El usuario `SYSDBA` y su contraseña se configuran
al instalar el paquete; sustituir `<password_sysdba>` por ese valor en los
comandos siguientes.

```bash
DB=localhost:/var/lib/firebird/data/vivero_nativacr.fdb

isql-fb -user SYSDBA -password '<password_sysdba>' -i sql/01_schema.sql
isql-fb -user SYSDBA -password '<password_sysdba>' $DB -i sql/02_seed.sql
isql-fb -user SYSDBA -password '<password_sysdba>' $DB -i sql/03_usuario_app.sql
isql-fb -user SYSDBA -password '<password_sysdba>' $DB -i sql/06_vistas.sql
isql-fb -user SYSDBA -password '<password_sysdba>' $DB -i sql/07_triggers.sql

for f in sql/04_paquetes/*.sql; do
  isql-fb -user SYSDBA -password '<password_sysdba>' $DB -i "$f"
done

isql-fb -user SYSDBA -password '<password_sysdba>' $DB -i sql/08_permisos_app.sql
```

Diccionario de datos (equivalente a exportar desde SQL Developer, pero para Firebird):

```bash
isql-fb -user SYSDBA -password '<password_sysdba>' $DB -i sql/05_diccionario_datos.sql
```

## Ejecución del programa

```bash
cd src
pip install -r requirements.txt
cp db_config.example.py db_config.py
```

Editar `db_config.py` con la ruta de la base, el usuario `vivero_app` y su
contraseña (creada en `sql/03_usuario_app.sql`).

```bash
python test_conexion.py
python vivero_app.py
```

Toda operación de `vivero_app.py` pasa por procedimientos almacenados de los
paquetes en `sql/04_paquetes/`; el usuario `vivero_app` no tiene permisos
directos sobre las tablas (solo `EXECUTE` sobre los paquetes).

Repositorio: https://github.com/haarias-cr/vivero-nativacr-lenguajes-bd-g8
