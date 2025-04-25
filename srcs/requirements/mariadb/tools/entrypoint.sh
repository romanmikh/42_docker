#!/bin/sh

# Load secrets
export USER_PASS=$(cat /run/secrets/db_user_password)
export ADMIN_PASS=$(cat /run/secrets/db_admin_password)
export ROOT_PASS=$(cat /run/secrets/db_root_password)

# Load env values
export MYSQL_DATABASE=${MYSQL_DATABASE}
export MYSQL_USER=${MYSQL_USER}
export MYSQL_ADMIN=${MYSQL_ADMIN}

# Replace variables into a writable place
envsubst < /init.sql.template > /tmp/init.sql

# Start MariaDB with correct init-file
exec mysqld --user=mysql --datadir=/var/lib/mysql --init-file=/tmp/init.sql