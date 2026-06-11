# Vivero NativaCR

Proyecto final de Lenguajes de Base de Datos (SC-504).  
Universidad Fidelitas, Grupo 8.

Sistema para un vivero de plantas nativas: inventario, pedidos y cuidados por lote.

**Integrantes:** Natalia Aguero, Harvi Arias, Camilo Montero

## Contenido del repositorio

| Carpeta | Descripción |
|---------|-------------|
| `docs/` | Avance I y documentación del proyecto |
| `sql/` | Scripts de la base de datos |
| `src/` | Programa en Python 3 |

## Instalación de la base de datos

Requiere MariaDB o MySQL.

```bash
sudo mysql < sql/01_schema.sql
sudo mysql < sql/02_seed.sql
sudo mysql < sql/04_app_user.sql
```

## Ejecución del programa

```bash
cd src
pip install -r requirements.txt
cp db_config.example.py db_config.py
```

Editar `db_config.py` con el host, usuario y contraseña de MariaDB.

```bash
python test_conexion.py
python vivero_app.py
```

Repositorio: https://github.com/haarias-cr/vivero-nativacr-lenguajes-bd-g8
