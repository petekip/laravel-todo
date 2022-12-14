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

# Install Composer
COPY . .
COPY composer.json composer.lock ./
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --no-autoloader


#RUN composer install --no-scripts --no-autoloader

#RUN chmod +x artisan

#RUN composer dump-autoload --optimize && composer run-script post-install-cmd



RUN chown -R www-data:www-data storage bootstrap
RUN chmod -R 777 storage bootstrap