# php: is ... an official image from Docker (maintained by PHP team)
# FPM needed for running PHP applications BUT doesn't speak HTTP, so NGINX needed
# alpine is lightweight, no GUI
FROM php:8.2.28-fpm-alpine

# below is equivalent beginning with FROM alpine:x.x.x, but is more heavyweight
# FROM alpine:3.20.6

# # Install PHP and FPM manually
# RUN apk add --no-cache php82 php82-fpm php82-mysqli php82-session php82-json php82-mbstring php82-curl php82-dom php82-opcache php82-phar php82-tokenizer php82-xml php82-zlib


# Install common dependencies
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

RUN chown -R www-data:www-data /var/www/html

# Add PHP info test pageEach Docker image must have the same name as its corresponding service.
COPY tools/phpinfo.php /var/www/html/phpinfo.php

# Log errors to stdout
RUN echo "display_errors = On" >> /usr/local/etc/php/php.ini \
    && echo "log_errors = On" >> /usr/local/etc/php/php.ini \
    && echo "error_log = /proc/self/fd/2" >> /usr/local/etc/php/php.ini

# delcarative only, does not open ports to internet
EXPOSE 9000
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

        