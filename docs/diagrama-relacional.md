# Diagrama relacional

Modelo en tercera forma normal. Ocho tablas:

```
zonas_biologicas
    └── especies
            └── lotes ──┬── invernaderos
                        ├── detalle_pedido ── pedidos ── clientes
                        └── cuidados_lote
```

## Tablas

| Tabla | Función |
|-------|---------|
| zonas_biologicas | Zona ecológica (bosque seco, lluvioso, páramo) |
| especies | Catálogo de plantas |
| invernaderos | Ubicación del cultivo |
| lotes | Inventario por especie |
| clientes | Compradores |
| pedidos | Encabezado de venta |
| detalle_pedido | Detalle de cada pedido |
| cuidados_lote | Riego, fertilización, poda, etc. |

Script completo: `sql/01_schema.sql`
