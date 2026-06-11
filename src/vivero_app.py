# Menú consola - Vivero NativaCR

from __future__ import annotations

from db import get_cursor


def listar_inventario() -> None:
    sql = """
        SELECT e.nombre_comun,
               e.nombre_cientifico,
               i.nombre AS invernadero,
               l.cantidad,
               l.estado
        FROM lotes l
        JOIN especies e ON e.id_especie = l.id_especie
        JOIN invernaderos i ON i.id_invernadero = l.id_invernadero
        WHERE l.estado = 'activo'
        ORDER BY e.nombre_comun
    """
    with get_cursor(dictionary=True) as cur:
        cur.execute(sql)
        rows = cur.fetchall()

    print("\n--- Inventario activo ---")
    for row in rows:
        print(
            f"{row['nombre_comun']:18} | {row['invernadero']:18} | "
            f"{row['cantidad']:4} u. | {row['estado']}"
        )


def listar_pedidos() -> None:
    sql = """
        SELECT p.id_pedido,
               c.nombre AS cliente,
               p.fecha_pedido,
               p.estado,
               p.total
        FROM pedidos p
        JOIN clientes c ON c.id_cliente = p.id_cliente
        ORDER BY p.fecha_pedido DESC
    """
    with get_cursor(dictionary=True) as cur:
        cur.execute(sql)
        rows = cur.fetchall()

    print("\n--- Pedidos ---")
    for row in rows:
        print(
            f"#{row['id_pedido']} | {row['cliente'][:28]:28} | "
            f"{row['estado']:10} | ₡{row['total']:,.2f}"
        )


def ventas_por_zona() -> None:
    sql = """
        SELECT z.nombre AS zona,
               SUM(d.cantidad) AS plantas,
               SUM(d.subtotal) AS monto
        FROM detalle_pedido d
        JOIN lotes l ON l.id_lote = d.id_lote
        JOIN especies e ON e.id_especie = l.id_especie
        JOIN zonas_biologicas z ON z.id_zona = e.id_zona
        GROUP BY z.id_zona, z.nombre
    """
    with get_cursor(dictionary=True) as cur:
        cur.execute(sql)
        rows = cur.fetchall()

    print("\n--- Ventas por zona biológica ---")
    for row in rows:
        print(f"{row['zona']:22} | {row['plantas']:3} plantas | ₡{row['monto']:,.2f}")


def registrar_cuidado() -> None:
    print("\n--- Registrar cuidado de lote ---")
    id_lote = input("ID del lote: ").strip()
    tipo = input("Tipo (riego/fertilizacion/poda/control_plagas/trasplante): ").strip()
    observaciones = input("Observaciones: ").strip()

    sql = """
        INSERT INTO cuidados_lote (id_lote, fecha_cuidado, tipo_cuidado, observaciones)
        VALUES (%s, CURDATE(), %s, %s)
    """
    with get_cursor() as cur:
        cur.execute(sql, (id_lote, tipo, observaciones))
    print("Cuidado registrado.")


MENU = {
    "1": ("Inventario activo", listar_inventario),
    "2": ("Pedidos", listar_pedidos),
    "3": ("Ventas por zona", ventas_por_zona),
    "4": ("Registrar cuidado", registrar_cuidado),
    "0": ("Salir", None),
}


def main() -> None:
    print("Vivero NativaCR")
    while True:
        print("\nMenú:")
        for key, (label, _) in MENU.items():
            print(f"  {key}. {label}")
        opcion = input("Opción: ").strip()
        if opcion == "0":
            print("Hasta luego.")
            break
        action = MENU.get(opcion)
        if not action:
            print("Opción inválida.")
            continue
        _, handler = action
        if handler:
            handler()


if __name__ == "__main__":
    main()
