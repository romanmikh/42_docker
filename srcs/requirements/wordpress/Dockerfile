# FPM needed for PHP apps but doesn't speak HTTP, so NGINX is needed
# alpine = lightweight, no GUI

# 3.19 latest version
FROM alpine:3.18 

# install PHP 8.1 + extensions + mariadb client + curl
RUN apk update && apk upgrade && apk add --no-cache \
    php81 php81-fpm php81-bcmath php81-bz2 php81-calendar php81-cli php81-ctype \
    php81-curl php81-dom php81-exif php81-fileinfo php81-gd php81-gmp \
    php81-iconv php81-imap php81-intl php81-json php81-mbstring \
    php81-mysqli php81-mysqlnd php81-openssl php81-pcntl php81-pdo php81-pdo_mysql \
    php81-phar php81-posix php81-session php81-simplexml php81-soap php81-sockets \
    php81-sqlite3 php81-tokenizer php81-xml php81-xmlreader php81-xmlwriter \
    php81-xsl php81-zip php81-zlib mariadb-client curl ca-certificates

# php-fpm should listen on TCP for nginx upstream, and clear env must be off
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf \
 && sed -i 's|^;*clear_env = .*|clear_env = no|' /etc/php81/php-fpm.d/www.conf

# install wp-cli
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/bin/wp-cli.phar \
 && chmod +x /usr/bin/wp-cli.phar
ENV WP_CLI_ALLOW_ROOT=1

# download WordPress into nginx docroot
WORKDIR /var/www/html
RUN curl -L https://wordpress.org/latest.tar.gz -o /tmp/wp.tgz \
 && tar -xzf /tmp/wp.tgz --strip-components=1 -C /var/www/html \
 && rm /tmp/wp.tgz \
 && adduser -S -D -H -s /sbin/nologin www-data || true \
 && chown -R www-data:www-data /var/www/html

# php logs should go to stderr so docker picks them up
RUN mkdir -p /etc/php81/conf.d \
 && { echo "display_errors=On"; echo "log_errors=On"; echo "error_log=/proc/self/fd/2"; } > /etc/php81/conf.d/zz-custom.ini

# copy in my entrypoint script
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

# entrypoint runs my init script (this will exec php-fpm in it)
ENTRYPOINT ["/entrypoint.sh"]


# # Run:
#     # docker run -it --rm -p 9000:9000 wordpress_fpm
#     # this should give "fpm is running, pid 1" & "ready to handle connections"
#     # PID 1 is the process ID of the main/first/init process in the container
#     # in our case, it's the PHP-FPM process

#     # PID 1 handles signals, so if it dies, the container dies
#     # sleep infinity or tail-f are alternatives to keep the container running, but don't handle signals well
#     # demo: 
#         # docker run -it alpine sleep infinity
#         # sudo docker ps (from new terminal, get the container ID)
#         # sudo docker stop <container_id>
#         # hangs for 10 seconds and dies ungracefully
#         # ---
#         # docker run -it php:8.2-fpm-alpine php-fpm
#         # sudo docker ps (from new terminal, get the container ID)
#         # sudo docker stop <container_id>
#         # dies immediately, even says 'bye-bye!'