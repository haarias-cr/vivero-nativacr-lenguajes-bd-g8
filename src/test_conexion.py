# Prueba de conexion a la BD (Firebird)

from __future__ import annotations

import sys

try:
    import firebird.driver  # noqa: F401
except ImportError:
    print("Falta firebird-driver. Ejecutar: pip install firebird-driver")
    sys.exit(1)

try:
    from db_config import DB_CONFIG  # noqa: F401
except ImportError:
    print("Crear db_config.py a partir de db_config.example.py")
    sys.exit(1)

from db import call_proc_query


def main() -> None:
    especies = call_proc_query("pkg_especies.sp_especie_listar_por_zona", (None,))
    print(f"Conexion OK. Especies en la BD: {len(especies)}")


if __name__ == "__main__":
    main()
