#!/bin/sh
set -e

if [ ! -f composer.json ]; then
    composer create-project "symfony/skeleton" tmp --stability=stable --prefer-dist --no-progress --no-interaction
    rm tmp/composer.json
    mv tmp/composer.tmp.json tmp/composer.json

    cp -Rp tmp/. .
    rm -Rf tmp/
fi

if [ "$APP_ENV" != 'prod' ]; then 
    composer install --prefer-dist --no-progress --no-suggest --no-interaction
else
    composer install --no-plugins --no-scripts --no-interaction --no-progress --no-suggest --no-dev
fi

### Doctrine: enable this if your project uses doctrine ###
# bin/console doctrine:database:create --if-not-exists
# bin/console doctrine:migrations:migrate -n

rm -rf var/cache/* var/log/*
chown -R www-data:www-data var/cache var/log

exec apache2-foreground