-- Usuario de la aplicacion Python - Firebird
-- Solo se le conceden permisos de EXECUTE sobre procedimientos/paquetes,
-- nunca acceso directo (SELECT/INSERT/UPDATE/DELETE) a las tablas.
-- Los GRANT EXECUTE se agregan en sql/08_permisos_app.sql una vez creados
-- los paquetes (no pueden existir permisos sobre objetos que aun no existen).
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 03_usuario_app.sql
-- Sustituir <password_vivero_app> por una contrasena real antes de ejecutar
-- (no se versiona la contrasena real; usar la misma en src/db_config.py).

CREATE USER vivero_app PASSWORD '<password_vivero_app>';

COMMIT;
