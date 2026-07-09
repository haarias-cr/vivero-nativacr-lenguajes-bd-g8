-- Permisos del usuario de aplicacion (vivero_app) - Firebird
-- Solo EXECUTE sobre los paquetes: sin SELECT/INSERT/UPDATE/DELETE directo
-- sobre tablas ni vistas, para forzar que toda operacion pase por un
-- procedimiento almacenado (regla del Avance II).
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 08_permisos_app.sql

GRANT EXECUTE ON PACKAGE pkg_zonas_biologicas TO vivero_app;
GRANT EXECUTE ON PACKAGE pkg_especies TO vivero_app;
GRANT EXECUTE ON PACKAGE pkg_invernaderos TO vivero_app;
GRANT EXECUTE ON PACKAGE pkg_lotes TO vivero_app;
GRANT EXECUTE ON PACKAGE pkg_clientes TO vivero_app;
GRANT EXECUTE ON PACKAGE pkg_pedidos TO vivero_app;
GRANT EXECUTE ON PACKAGE pkg_detalle_pedido TO vivero_app;
GRANT EXECUTE ON PACKAGE pkg_cuidados_lote TO vivero_app;
GRANT EXECUTE ON PACKAGE pkg_reportes TO vivero_app;
GRANT EXECUTE ON PACKAGE pkg_utilidades TO vivero_app;

COMMIT;
