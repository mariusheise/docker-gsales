#!/bin/bash
set -e

if [ -e  ${GSALES_HOME}/lib/inc.cfg.php ]; then
    exec "$@"
    exit 0
fi

if [ -n "$MYSQL_HOST" ] && [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ] && [ -n "$MYSQL_DATABASE" ]; then

cat >>$GSALES_HOME/lib/inc.cfg.php <<-EOF
<?php
\$db = array();
\$db[0]['host'] = '${MYSQL_HOST}';
\$db[0]['user'] = '${MYSQL_USER}';
\$db[0]['password'] = '${MYSQL_PASSWORD}';
\$db[0]['database'] = '${MYSQL_DATABASE}';
define('_DATABASECON', serialize(\$db));
EOF

chown -R www-data:www-data ${GSALES_HOME}/lib/inc.cfg.php
chmod 600 ${GSALES_HOME}/lib/inc.cfg.php

fi

exec "$@"
