#!/bin/bash
# Instala la base de datos vivero_nativacr

DIR="$(cd "$(dirname "$0")" && pwd)"

sudo mysql < "$DIR/01_schema.sql"
sudo mysql < "$DIR/02_seed.sql"
sudo mysql < "$DIR/04_app_user.sql"

echo "Listo."
sudo mysql -e "USE vivero_nativacr; SHOW TABLES;"
