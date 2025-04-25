# objective:
# setup MariaDB container with Alpine image
# persistent volume for data (outside of container)
# env variables for configuration, no hardcoded passwords. MariaDB expects these

FROM alpine:3.20.6 

# apk = alpine package manager, --no-cache keeps image size small (no temp files)
# mariadb = server, mariadb-client = client binary needed to execute SQL
RUN apk add --no-cache mariadb mariadb-client envsubst

# official MariaDB image looks for .sql or .sh files in /docker-entrypoint-initdb.d/
# that's forbidden, so we mimic this behavior manually
COPY tools/ /docker-entrypoint-initdb.d/
# COPY tools/init.sql /init.sql
COPY tools/init.sql.template /init.sql.template
# needed to replace ${} with env vars
RUN apk add --no-cache gettext 
    # && envsubst < /init.sql.template > /init.sql

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


# /run/mysqld is where MariaDB stores its PID & socket files — refuses to start without it
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# MariaDB needs this for system tables
RUN mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# MariaDB config
COPY conf/my.cnf /etc/my.cnf

# Set permissions — this is where MariaDB stores DBs
# Docker will later mount a volume here for persistence
RUN chown -R mysql:mysql /var/lib/mysql

# delcarative only, does not open ports to internet
EXPOSE 3306

# Start the daemon, then run init.sql to set up DB + user
USER mysql
CMD ["sh", "-c", "mysqld --user=mysql --datadir=/var/lib/mysql --init-file=/tmp/init.sql"]




# Run:
# docker build -t mariadb_custom srcs/requirements/mariadb
# this builds new image from Dockerfile, called mariadb_custom
# path tells docker where to look for Dockerfile