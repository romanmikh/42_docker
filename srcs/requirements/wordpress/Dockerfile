# php: is ... an official image from Docker (maintained by PHP team)
# FPM needed for running PHP applications BUT doesn't speak HTTP, so NGINX needed
# alpine is lightweight, no GUI
FROM php:8.2-fpm-alpine



# Install common dependencies
# RUN apk add --no-cache \
#     curl \
#     mysql-client \
#     bash \
#     php-mysqli \
#     php-phar \
#     php-json \
#     php-mbstring \
#     php-session \
#     php-zlib \
#     php-curl \
#     php-gd \
#     php-dom \
#     php-exif \
#     php-opcache \
#     php-fileinfo \
#     php-tokenizer \
#     php-xml \
#     php-ctype

RUN apk add --no-cache \
bash \
curl \
mariadb-client \
libpng-dev \
libjpeg-turbo-dev \
libwebp-dev \
libxpm-dev \
freetype-dev \
libzip-dev \
libxml2-dev \
oniguruma-dev \
zlib-dev \
autoconf \
g++ \
make

# extension to meet requirements in browser
RUN docker-php-ext-install mysqli zip xml pdo pdo_mysql gd mbstring

# Download WordPress
# WORKDIR is the directory where the command will be executed
# /var/www/html is the standard doc root for NGINX, WordPress expects this
WORKDIR /var/www/html
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz

# Fix permissions
# RUN chown -R www-data:www-data /var/www/html

# COPY tools/phpinfo.php /var/www/html/phpinfo.php

# RUN echo "display_errors = On" >> /usr/local/etc/php/php.ini \
#     && echo "log_errors = On" >> /usr/local/etc/php/php.ini \
#     && echo "error_log = /proc/self/fd/2" >> /usr/local/etc/php/php.ini

# EXPOSE 9000

# # Start PHP-FPM server (CMD -> on container start)
# # docker run -it php:8.2-fpm-alpine php-fpm  <- equicalent of CMD ["php-fpm"]
# CMD ["php-fpm"]

RUN chown -R www-data:www-data /var/www/html

# Add PHP info test page
COPY tools/phpinfo.php /var/www/html/phpinfo.php

# Log errors to stdout
RUN echo "display_errors = On" >> /usr/local/etc/php/php.ini \
    && echo "log_errors = On" >> /usr/local/etc/php/php.ini \
    && echo "error_log = /proc/self/fd/2" >> /usr/local/etc/php/php.ini

EXPOSE 9000
# CMD ["php-fpm"]
CMD ["php-fpm", "-F"]



# Run:
    # docker run -it --rm -p 9000:9000 wordpress_fpm
    # this should give "fpm is running, pid 1" & "ready to handle connections"
    # PID 1 is the process ID of the main/first/init process in the container
    # in our case, it's the PHP-FPM process

    # PID 1 handles signals, so if it dies, the container dies
    # sleep infinity or tail-f are alternatives to keep the container running, but don't handle signals well
    # demo: 
        # docker run -it alpine sleep infinity
        # sudo docker ps (from new terminal, get the container ID)
        # sudo docker stop <container_id>
        # hangs for 10 seconds and dies ungracefully
        # ---
        # docker run -it php:8.2-fpm-alpine php-fpm
        # sudo docker ps (from new terminal, get the container ID)
        # sudo docker stop <container_id>
        # dies immediately, even says 'bye-bye!'