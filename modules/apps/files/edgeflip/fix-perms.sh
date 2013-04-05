#!/bin/bash

ROOT='/var/www/edgeflip'

chown -R www-data:www-data ${ROOT}
find ${ROOT}/. -type d -exec chmod 755 {} \;
