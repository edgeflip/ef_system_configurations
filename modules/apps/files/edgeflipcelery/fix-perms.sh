#!/bin/bash

ROOT='/var/www/edgeflipcelery'

chown -R www-data:www-data ${ROOT}
find ${ROOT}/. -type d -exec chmod 755 {} \;
