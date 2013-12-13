#!/bin/bash

ROOT='/var/www/sentry'

chown -R www-data:www-data ${ROOT}
find ${ROOT}/. -type d -exec chmod 755 {} \;
