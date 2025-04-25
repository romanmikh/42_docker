# objective:
# 'reverse-proxy' means routing traffic to other containers
# we do this via php-fpm via internal Docker network
# enable HTTPS (TLS v1.2 or 1.3)
# expose port 443 only (not 80 (HTTP))
# basically after this, we will have a working HTTPS server & website

FROM alpine:3.18

RUN apk add --no-cache nginx openssl gettext

# Copy NGINX config
ARG DOMAIN
ENV DOMAIN=$DOMAIN
COPY conf/default.conf.template /etc/nginx/templates/default.conf.template
RUN envsubst '${DOMAIN}' < /etc/nginx/templates/default.conf.template > /etc/nginx/http.d/default.conf

# Create self-signed cert (temporary)
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=UK/ST=London/L=London/O=42/OU=Dev/CN=localhost" \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt

EXPOSE 443

# nginx -g "daemon off"
# starts nginx soerver and keeps it running in foreground (so it doesn't exit)
CMD ["nginx", "-g", "daemon off;"]