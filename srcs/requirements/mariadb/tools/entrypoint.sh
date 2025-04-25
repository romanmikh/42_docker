#!/bin/sh

# Read secrets
USER_PASS=$(cat /run/secrets/db_user_password)
ADMIN_PASS=$(cat /run/secrets/db_admin_password)
ROOT_PASS=$(cat /run/secrets/db_root_password)

# Inject into init.sql (template -> final)
envsubst < /init.sql.template > /init.sql

# Start DB
exec mysqld --user=mysql --datadir=/var/lib/mysql