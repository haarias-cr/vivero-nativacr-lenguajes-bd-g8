-- Usuario para la aplicacion Python
USE vivero_nativacr;

CREATE USER IF NOT EXISTS 'vivero_app'@'%' IDENTIFIED BY 'ViveroNativa2026!';
CREATE USER IF NOT EXISTS 'vivero_app'@'localhost' IDENTIFIED BY 'ViveroNativa2026!';

GRANT SELECT, INSERT, UPDATE, DELETE ON vivero_nativacr.* TO 'vivero_app'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON vivero_nativacr.* TO 'vivero_app'@'localhost';

FLUSH PRIVILEGES;
