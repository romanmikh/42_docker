-- This file is used to initialize the database and create a user for WordPress
-- It should be executed when the container is started for the first time
-- The database and user (with all privileges) will be created if they do not already exist

-- Database name: wordpress_db
-- User name: wordpress_user
-- User password: wordpress_pass
-- Host: %, means that the user can connect from any host

CREATE DATABASE IF NOT EXISTS wordpress_db;
CREATE USER IF NOT EXISTS 'wordpress_user'@'%' IDENTIFIED BY 'wordpress_pass';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'%';

-- tells mariaDB to reload user permissions immediately (like the new user added)
-- it's best practice at end of CREATE USER / GRANT scripts
FLUSH PRIVILEGES;