#Import the image with basic ubuntu system and php along with extensions installed.
FROM php:8.1-apache

# Copy local code to the container image.
COPY . /var/www/html/

# Restart apache2
RUN service apache2 restart

# Use the PORT environment variable in Apache configuration files.
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf


# Authorise .htaccess files
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

COPY .env.example .env

ARG GOOGLE_CLOUD_PROJECT

RUN sed -ri -e 's/project_id/${GOOGLE_CLOUD_PROJECT}/g' .env

# Install composer packages


# Install Composer
# Install composer
ENV COMPOSER_HOME /composer
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
# Install PHP_CodeSniffer
RUN composer global require "squizlabs/php_codesniffer=*"

# Cleanup dev dependencies
RUN apk del -f .build-deps

# Setup working directory
WORKDIR /var/www/html

COPY composer.json composer.json
#COPY composer.lock composer.lock
COPY . .
RUN composer install
RUN composer dump-autoload

RUN php artisan key:generate
RUN php artisan jwt:secret
RUN chmod 777 -R storage