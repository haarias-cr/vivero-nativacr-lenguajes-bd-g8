-- Paquete 5/10: clientes
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 05_pkg_clientes.sql

SET TERM ^ ;

CREATE PACKAGE pkg_clientes
SQL SECURITY DEFINER
AS
BEGIN
  PROCEDURE sp_cliente_insertar(nombre VARCHAR(100), telefono VARCHAR(20), correo VARCHAR(120),
      tipo VARCHAR(12))
    RETURNS (id_cliente INTEGER);
  PROCEDURE sp_cliente_actualizar(id_cliente INTEGER, nombre VARCHAR(100), telefono VARCHAR(20),
      correo VARCHAR(120), tipo VARCHAR(12));
  PROCEDURE sp_cliente_eliminar(id_cliente INTEGER);
  PROCEDURE sp_cliente_listar
    RETURNS (id_cliente INTEGER, nombre VARCHAR(100), tipo VARCHAR(12),
      total_pedidos INTEGER, monto_acumulado DECIMAL(12,2));

  FUNCTION fn_cliente_existe(id_cliente INTEGER) RETURNS BOOLEAN;
END^

CREATE PACKAGE BODY pkg_clientes
AS
BEGIN
  PROCEDURE sp_cliente_insertar(nombre VARCHAR(100), telefono VARCHAR(20), correo VARCHAR(120),
      tipo VARCHAR(12))
    RETURNS (id_cliente INTEGER)
  AS
  BEGIN
    INSERT INTO clientes (nombre, telefono, correo, tipo)
      VALUES (:nombre, :telefono, :correo, :tipo)
      RETURNING clientes.id_cliente INTO :id_cliente;
  END

  PROCEDURE sp_cliente_actualizar(id_cliente INTEGER, nombre VARCHAR(100), telefono VARCHAR(20),
      correo VARCHAR(120), tipo VARCHAR(12))
  AS
  BEGIN
    UPDATE clientes SET nombre = :nombre, telefono = :telefono, correo = :correo, tipo = :tipo
      WHERE clientes.id_cliente = :id_cliente;
  END

  PROCEDURE sp_cliente_eliminar(id_cliente INTEGER)
  AS
  BEGIN
    DELETE FROM clientes WHERE clientes.id_cliente = :id_cliente;
  END

  PROCEDURE sp_cliente_listar
    RETURNS (id_cliente INTEGER, nombre VARCHAR(100), tipo VARCHAR(12),
      total_pedidos INTEGER, monto_acumulado DECIMAL(12,2))
  AS
  BEGIN
    FOR SELECT v.id_cliente, v.nombre, v.tipo, v.total_pedidos, v.monto_acumulado
        FROM v_clientes_resumen v
        ORDER BY v.nombre
        AS CURSOR c_clientes
    DO
    BEGIN
      id_cliente = c_clientes.id_cliente;
      nombre = c_clientes.nombre;
      tipo = c_clientes.tipo;
      total_pedidos = c_clientes.total_pedidos;
      monto_acumulado = c_clientes.monto_acumulado;
      SUSPEND;
    END
  END

  FUNCTION fn_cliente_existe(id_cliente INTEGER) RETURNS BOOLEAN
  AS
  BEGIN
    RETURN EXISTS(SELECT 1 FROM clientes c WHERE c.id_cliente = :id_cliente);
  END
END^

SET TERM ; ^

COMMIT;
