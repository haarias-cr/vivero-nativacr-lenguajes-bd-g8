# Conexión a MariaDB

from __future__ import annotations

from contextlib import contextmanager
from typing import Generator, Any

import mysql.connector
from mysql.connector import MySQLConnection
from mysql.connector.cursor import MySQLCursor

from db_config import DB_CONFIG


@contextmanager
def get_connection() -> Generator[MySQLConnection, None, None]:
    conn = mysql.connector.connect(**DB_CONFIG)
    try:
        yield conn
    finally:
        conn.close()


@contextmanager
def get_cursor(dictionary: bool = False) -> Generator[MySQLCursor, None, None]:
    with get_connection() as conn:
        cursor = conn.cursor(dictionary=dictionary)
        try:
            yield cursor
            conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            cursor.close()
