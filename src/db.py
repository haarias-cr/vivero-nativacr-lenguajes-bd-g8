# Conexion a Firebird y helpers para invocar procedimientos almacenados.
# Toda operacion de la aplicacion pasa por un procedimiento del paquete
# correspondiente: este modulo nunca ejecuta SELECT/INSERT/UPDATE/DELETE
# directo sobre tablas (el usuario vivero_app ni siquiera tiene permiso).

from __future__ import annotations

from contextlib import contextmanager
from typing import Any, Generator, Sequence

from firebird.driver import Connection, connect

from db_config import DB_CONFIG


@contextmanager
def get_connection() -> Generator[Connection, None, None]:
    con = connect(DB_CONFIG["database"], user=DB_CONFIG["user"], password=DB_CONFIG["password"])
    try:
        yield con
    finally:
        con.close()


def call_proc_exec(nombre_proc: str, params: Sequence[Any] = ()) -> tuple | None:
    """Ejecuta un procedimiento almacenado no selectable (alta/baja/cambio de
    estado) y devuelve su fila de salida si la tiene (p. ej. un id generado)."""
    placeholders = ", ".join(["?"] * len(params))
    sql = f"EXECUTE PROCEDURE {nombre_proc}({placeholders})" if params else f"EXECUTE PROCEDURE {nombre_proc}"
    with get_connection() as con:
        cur = con.cursor()
        try:
            cur.execute(sql, params)
            row = cur.fetchone()
            con.commit()
            return row
        except Exception:
            con.rollback()
            raise


def call_proc_query(nombre_proc: str, params: Sequence[Any] = ()) -> list[dict[str, Any]]:
    """Llama un procedimiento selectable (usa SUSPEND internamente) y
    devuelve todas las filas como diccionarios columna -> valor."""
    placeholders = ", ".join(["?"] * len(params))
    sql = f"SELECT * FROM {nombre_proc}({placeholders})" if params else f"SELECT * FROM {nombre_proc}"
    with get_connection() as con:
        cur = con.cursor()
        cur.execute(sql, params)
        columnas = [d[0].lower() for d in cur.description]
        return [dict(zip(columnas, fila)) for fila in cur.fetchall()]
