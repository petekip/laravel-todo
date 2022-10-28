FROM composer:2.0 as build
WORKDIR /app
COPY . /app
RUN composer install --no-scripts --no-autoloader && \
    composer dump-autoload --optimize

FROM php:8.0-apache-stretch

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    mysql-client

RUN docker-php-ext-install pdo pdo_mysql mysqli

EXPOSE 8080
COPY --from=build /app /var/www/
COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN  chown -R www-data:www-data /var/www/;
RUN  find /var/www/ -type f -exec chmod 644 {} \;
RUN  find /var/www/ -type d -exec chmod 755 {} \;

RUN cd /var/www/ && \
    mv .env.example .env && \
    php artisan key:generate && \
    chgrp -R www-data storage bootstrap/cache && \
    chmod -R ug+rwx storage bootstrap/cache && \
    echo "Listen 8080" >> /etc/apache2/ports.conf && \
    a2enmod rewrite