FROM php:7.4-apache

RUN apt-get update && apt-get install -y zlib1g-dev libicu-dev g++ git zip libxslt-dev jq

RUN a2enmod rewrite

RUN docker-php-ext-install pdo_mysql intl xsl

EXPOSE 80

# Configure vhosts
COPY ./.docker/vhosts.conf /etc/apache2/sites-enabled/vhosts.conf
RUN rm /etc/apache2/sites-enabled/000-default.conf

# Restart apache to apply changes
RUN service apache2 restart

# Install project files
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html
WORKDIR /var/www/html
COPY . .
RUN chown -R www-data:www-data .

ARG WITH_XDEBUG=false

RUN if [ $WITH_XDEBUG = "true" ] ; then \
        pecl install xdebug \
        && docker-php-ext-enable xdebug \
        && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    fi ;

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
&& composer --version

# Configure entry point
COPY .docker/entrypoint.sh /usr/local/bin/app-docker-entrypoint
RUN chmod +x /usr/local/bin/app-docker-entrypoint
ENTRYPOINT ["app-docker-entrypoint"]
CMD ["php"]
