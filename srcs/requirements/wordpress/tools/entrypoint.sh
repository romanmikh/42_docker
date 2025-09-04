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

/usr/bin/wp-cli.phar core is-installed --path=/var/www/html --allow-root || \
/usr/bin/wp-cli.phar core install \
  --url="https://${DOMAIN}" \
  --title="${WP_TITLE}" \
  --admin_user="${WP_ADMIN_USER}" \
  --admin_password="${WP_ADMIN_PASS}" \
  --admin_email="${WP_ADMIN_EMAIL}" \
  --skip-email \
  --path=/var/www/html \
  --allow-root

# subscriber (idempotent)
 /usr/bin/wp-cli.phar user get "$WP_USER" \
   --path=/var/www/html --allow-root >/dev/null 2>&1 || \
 /usr/bin/wp-cli.phar user create "$WP_USER" "$WP_USER_EMAIL" \
   --user_pass="$WP_USER_PASS" --role=subscriber \
   --path=/var/www/html --allow-root

# admin safety net (idempotent)
 /usr/bin/wp-cli.phar user get "$WP_ADMIN_USER" \
   --path=/var/www/html --allow-root >/dev/null 2>&1 || \
 /usr/bin/wp-cli.phar user create "$WP_ADMIN_USER" "$WP_ADMIN_EMAIL" \
   --user_pass="$WP_ADMIN_PASS" --role=administrator \
   --path=/var/www/html --allow-root

 /usr/bin/wp-cli.phar user update "$WP_USER" --user_pass="$WP_USER_PASS" \
   --path=/var/www/html --allow-root
 /usr/bin/wp-cli.phar user update "$WP_ADMIN_USER" --user_pass="$WP_ADMIN_PASS" \
   --path=/var/www/html --allow-root

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
