# Menu consola - Vivero NativaCR (Firebird)
# Todas las operaciones se realizan a traves de procedimientos almacenados
# agrupados en paquetes (pkg_*). No hay ninguna consulta SQL directa aqui.

from __future__ import annotations

from db import call_proc_exec, call_proc_query


def listar_inventario() -> None:
    filas = call_proc_query("pkg_lotes.sp_lote_listar_activos")

    print("\n--- Inventario activo ---")
    for f in filas:
        print(
            f"{f['nombre_comun']:18} | {f['invernadero']:18} | "
            f"{f['cantidad']:4} u. | {f['estado']}"
        )


def listar_pedidos() -> None:
    filas = call_proc_query("pkg_pedidos.sp_pedido_listar")

    print("\n--- Pedidos ---")
    for f in filas:
        print(
            f"#{f['id_pedido']} | {f['cliente'][:28]:28} | "
            f"{f['estado']:10} | ₡{f['total']:,.2f}"
        )


def ventas_por_zona() -> None:
    filas = call_proc_query("pkg_reportes.sp_reporte_ventas_zona")

    print("\n--- Ventas por zona biologica ---")
    for f in filas:
        print(f"{f['zona']:22} | {f['plantas_vendidas']:3} plantas | ₡{f['monto_total']:,.2f}")


def registrar_cuidado() -> None:
    print("\n--- Registrar cuidado de lote ---")
    id_lote = input("ID del lote: ").strip()
    tipo = input("Tipo (riego/fertilizacion/poda/control_plagas/trasplante): ").strip()
    observaciones = input("Observaciones: ").strip()

    call_proc_exec("pkg_cuidados_lote.sp_cuidado_insertar", (int(id_lote), tipo, observaciones))
    print("Cuidado registrado.")


def registrar_especie() -> None:
    print("\n--- Registrar especie ---")
    id_zona = input("ID de zona biologica: ").strip()
    nombre_cientifico = input("Nombre cientifico: ").strip()
    nombre_comun = input("Nombre comun: ").strip()
    precio_unitario = input("Precio unitario: ").strip()
    descripcion = input("Descripcion (opcional): ").strip() or None

    fila = call_proc_exec(
        "pkg_especies.sp_especie_insertar",
        (int(id_zona), nombre_cientifico, nombre_comun, float(precio_unitario), descripcion),
    )
    print(f"Especie registrada con id {fila[0]}.")


def registrar_cliente() -> None:
    print("\n--- Registrar cliente ---")
    nombre = input("Nombre: ").strip()
    telefono = input("Telefono (opcional): ").strip() or None
    correo = input("Correo (opcional): ").strip() or None
    tipo = input("Tipo (persona/institucion) [persona]: ").strip() or "persona"

    fila = call_proc_exec("pkg_clientes.sp_cliente_insertar", (nombre, telefono, correo, tipo))
    print(f"Cliente registrado con id {fila[0]}.")


def crear_pedido() -> None:
    print("\n--- Crear pedido ---")
    id_cliente = input("ID del cliente: ").strip()
    fila = call_proc_exec("pkg_pedidos.sp_pedido_insertar", (int(id_cliente),))
    id_pedido = fila[0]
    print(f"Pedido #{id_pedido} creado (pendiente). Agregue lineas de detalle:")

    while True:
        id_lote = input("  ID de lote a agregar (Enter para terminar): ").strip()
        if not id_lote:
            break
        cantidad = input("  Cantidad: ").strip()
        try:
            detalle = call_proc_exec(
                "pkg_detalle_pedido.sp_detalle_insertar", (id_pedido, int(id_lote), int(cantidad))
            )
            print(f"  Linea agregada (id_detalle={detalle[0]}).")
        except Exception as exc:
            print(f"  No se pudo agregar la linea: {exc}")


def confirmar_pedido() -> None:
    print("\n--- Confirmar pedido ---")
    id_pedido = input("ID del pedido: ").strip()
    try:
        call_proc_exec("pkg_pedidos.sp_pedido_confirmar", (int(id_pedido),))
        print("Pedido confirmado.")
    except Exception as exc:
        print(f"No se pudo confirmar: {exc}")


def cancelar_pedido() -> None:
    print("\n--- Cancelar pedido ---")
    id_pedido = input("ID del pedido: ").strip()
    call_proc_exec("pkg_pedidos.sp_pedido_cancelar", (int(id_pedido),))
    print("Pedido cancelado y stock repuesto.")


MENU = {
    "1": ("Inventario activo", listar_inventario),
    "2": ("Pedidos", listar_pedidos),
    "3": ("Ventas por zona", ventas_por_zona),
    "4": ("Registrar cuidado", registrar_cuidado),
    "5": ("Registrar especie", registrar_especie),
    "6": ("Registrar cliente", registrar_cliente),
    "7": ("Crear pedido", crear_pedido),
    "8": ("Confirmar pedido", confirmar_pedido),
    "9": ("Cancelar pedido", cancelar_pedido),
    "0": ("Salir", None),
}


def main() -> None:
    print("Vivero NativaCR")
    while True:
        print("\nMenu:")
        for key, (label, _) in MENU.items():
            print(f"  {key}. {label}")
        opcion = input("Opcion: ").strip()
        if opcion == "0":
            print("Hasta luego.")
            break
        accion = MENU.get(opcion)
        if not accion:
            print("Opcion invalida.")
            continue
        _, handler = accion
        if handler:
            handler()


if __name__ == "__main__":
    main()
