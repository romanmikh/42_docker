FROM alpine:3.17

# PHP 8.1 + deps (matches the working reference you shared)
RUN apk update && apk upgrade && apk add --no-cache \
    php81 php81-fpm php81-bcmath php81-bz2 php81-calendar php81-cli php81-ctype \
    php81-curl php81-dom php81-exif php81-fileinfo php81-gd php81-gmp \
    php81-iconv php81-imap php81-intl php81-json php81-mbstring \
    php81-mysqli php81-mysqlnd php81-openssl php81-pcntl php81-pdo php81-pdo_mysql \
    php81-phar php81-posix php81-session php81-simplexml php81-soap php81-sockets \
    php81-sqlite3 php81-tokenizer php81-xml php81-xmlreader php81-xmlwriter \
    php81-xsl php81-zip php81-zlib mariadb-client curl ca-certificates

# php-fpm listen on TCP for nginx upstream
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf \
 && sed -i 's|^;*clear_env = .*|clear_env = no|' /etc/php81/php-fpm.d/www.conf

# WP-CLI
# RUN curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
#  && chmod +x /usr/local/bin/wp
RUN apk add --no-cache curl && \
    curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/bin/wp-cli.phar && \
    chmod +x /usr/bin/wp-cli.phar
ENV WP_CLI_ALLOW_ROOT=1

# WordPress in nginx docroot (no extra /wordpress subfolder)
WORKDIR /var/www/html
RUN curl -L https://wordpress.org/latest.tar.gz -o /tmp/wp.tgz \
 && tar -xzf /tmp/wp.tgz --strip-components=1 -C /var/www/html \
 && rm /tmp/wp.tgz \
 && adduser -S -D -H -s /sbin/nologin www-data || true \
 && chown -R www-data:www-data /var/www/html

# Optional test page
COPY tools/phpinfo.php /var/www/html/phpinfo.php

# PHP logging → stderr
RUN mkdir -p /etc/php81/conf.d \
 && { echo "display_errors=On"; echo "log_errors=On"; echo "error_log=/proc/self/fd/2"; } > /etc/php81/conf.d/zz-custom.ini

# Your existing init script
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/php-fpm81","-F"]




# # php: is ... an official image from Docker (maintained by PHP team)
# # FPM needed for running PHP applications BUT doesn't speak HTTP, so NGINX needed
# # alpine is lightweight, no GUI
# FROM php:8.2.28-fpm-alpine

# # below is equivalent beginning with FROM alpine:x.x.x, but is more heavyweight
# # FROM alpine:3.20.6

# # # Install PHP and FPM manually
# # RUN apk add --no-cache php82 php82-fpm php82-mysqli php82-session php82-json php82-mbstring php82-curl php82-dom php82-opcache php82-phar php82-tokenizer php82-xml php82-zlib


# # Install common dependencies
# RUN apk add --no-cache \
#     bash \
#     curl \
#     mariadb-client \
#     libpng-dev \
#     libjpeg-turbo-dev \
#     libwebp-dev \
#     libxpm-dev \
#     freetype-dev \
#     libzip-dev \
#     libxml2-dev \
#     oniguruma-dev \
#     zlib-dev \
#     autoconf \
#     g++ \
#     make

# # extension to meet requirements in browser
# RUN docker-php-ext-install mysqli zip xml pdo pdo_mysql gd mbstring

# # Download WordPress
# # WORKDIR is the directory where the command will be executed
# # /var/www/html is the standard doc root for NGINX, WordPress expects this
# WORKDIR /var/www/html
# RUN curl -O https://wordpress.org/latest.tar.gz && \
#     tar -xzf latest.tar.gz --strip-components=1 && \
#     rm latest.tar.gz

# RUN chown -R www-data:www-data /var/www/html

# # Add PHP info test pageEach Docker image must have the same name as its corresponding service.
# COPY tools/phpinfo.php /var/www/html/phpinfo.php

# # Log errors to stdout
# RUN echo "display_errors = On" >> /usr/local/etc/php/php.ini \
#     && echo "log_errors = On" >> /usr/local/etc/php/php.ini \
#     && echo "error_log = /proc/self/fd/2" >> /usr/local/etc/php/php.ini

# # delcarative only, does not open ports to internet
# EXPOSE 9000
# CMD ["php-fpm", "-F"]

# COPY tools/entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]


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

        