#!/bin/sh
set -eu

# --- secrets/env ---
PW="${WORDPRESS_DB_PASSWORD:-}"
[ -z "${PW}" ] && [ -f /run/secrets/db_user_password ] && PW="$(cat /run/secrets/db_user_password)"
: "${WORDPRESS_DB_NAME:?Missing WORDPRESS_DB_NAME}"
: "${WORDPRESS_DB_USER:?Missing WORDPRESS_DB_USER}"
: "${WORDPRESS_DB_HOST:?Missing WORDPRESS_DB_HOST}"
WORDPRESS_DB_PASSWORD="${PW}"

# --- wp-config.php bootstrap ---
if [ ! -f /var/www/html/wp-config.php ]; then
  cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
  sed -i \
    -e "s/database_name_here/${WORDPRESS_DB_NAME}/" \
    -e "s/username_here/${WORDPRESS_DB_USER}/" \
    -e "s/password_here/${WORDPRESS_DB_PASSWORD}/" \
    -e "s/localhost/${WORDPRESS_DB_HOST}/" \
    /var/www/html/wp-config.php
fi

# --- permissive ownership for dev ---
chown -R www-data:www-data /var/www/html

# --- optional: wait briefly for DB if nc available ---
if command -v nc >/dev/null 2>&1; then
  HOST="${WORDPRESS_DB_HOST%:*}"; PORT="${WORDPRESS_DB_HOST##*:}"
  [ "${HOST}" = "${PORT}" ] && HOST="${WORDPRESS_DB_HOST}" && PORT=3306
  i=0; until nc -z "${HOST}" "${PORT}" 2>/dev/null || [ $i -ge 30 ]; do i=$((i+1)); sleep 1; done
fi

exec /usr/sbin/php-fpm81 -F





# WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_user_password)

# if [ ! -f /var/www/html/wp-config.php ]; then
#   cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

#   sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
#   sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php
#   sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" /var/www/html/wp-config.php
#   sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php
# fi

# exec php-fpm -F
