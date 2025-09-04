#!/bin/sh

# --- secrets/env ---
WORDPRESS_DB_PASSWORD="$(cat /run/secrets/db_user_password)"

# --- wp-config.php ---
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php  # overwrite config for each run
sed -i \
  -e "s/database_name_here/${WORDPRESS_DB_NAME}/" \
  -e "s/username_here/${WORDPRESS_DB_USER}/" \
  -e "s/password_here/${WORDPRESS_DB_PASSWORD}/" \
  -e "s/localhost/${WORDPRESS_DB_HOST}/" \
  /var/www/html/wp-config.php  # inject DB settings into config

# --- install WP if needed ---
/usr/bin/wp-cli.phar core is-installed --path=/var/www/html --url="https://${DOMAIN}" --allow-root || \
/usr/bin/wp-cli.phar core install \
  --url="https://${DOMAIN}" \
  --title="${WP_TITLE}" \
  --admin_user="${WP_ADMIN_USER}" \
  --admin_password="${WP_ADMIN_PASS}" \
  --admin_email="${WP_ADMIN_EMAIL}" \
  --skip-email \
  --path=/var/www/html \
  --allow-root

# --- ensure users exist on fresh volumes ---
/usr/bin/wp-cli.phar user get "$WP_USER" --path=/var/www/html --allow-root >/dev/null 2>&1 || \
/usr/bin/wp-cli.phar user create "$WP_USER" "$WP_USER_EMAIL" \
  --user_pass="$WP_USER_PASS" --role=subscriber \
  --path=/var/www/html --allow-root

/usr/bin/wp-cli.phar user get "$WP_ADMIN_USER" --path=/var/www/html --allow-root >/dev/null 2>&1 || \
/usr/bin/wp-cli.phar user create "$WP_ADMIN_USER" "$WP_ADMIN_EMAIL" \
  --user_pass="$WP_ADMIN_PASS" --role=administrator \
  --path=/var/www/html --allow-root

# --- users, always sync password ---
/usr/bin/wp-cli.phar user update "$WP_USER"       --user_pass="$WP_USER_PASS"  --path=/var/www/html --allow-root
/usr/bin/wp-cli.phar user update "$WP_ADMIN_USER" --user_pass="$WP_ADMIN_PASS" --path=/var/www/html --allow-root

exec /usr/sbin/php-fpm81 -F
