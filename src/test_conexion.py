# Prueba de conexión a la BD

from __future__ import annotations

import sys

try:
    import mysql.connector
except ImportError:
    print("Falta mysql-connector-python. Ejecutar: pip install mysql-connector-python")
    sys.exit(1)

try:
    from db_config import DB_CONFIG
except ImportError:
    print("Crear db_config.py a partir de db_config.example.py")
    sys.exit(1)


def main() -> None:
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM especies")
    (total,) = cursor.fetchone()
    print(f"Conexion OK. Especies en la BD: {total}")
    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()
