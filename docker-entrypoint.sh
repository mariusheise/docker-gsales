#!/bin/bash
set -e

if [ -n "$MYSQL_NAME" ]; then

	if [ -z "$MYSQL_PASSWORD" ]; then
		MYSQL_PASSWORD=`pwgen -c -n -1 12`
	fi

	if [ -z "$MYSQL_USER" ]; then
		MYSQL_USER=gsales
	fi
	
	if [ -z "$MYSQL_DATABASE" ]; then
		MYSQL_DATABASE=gsales
	fi


	cat >> $GSALES_HOME/lib/inc.cfg.php <<-EOF
<?php
$db = array();
$db[0]['host'] = '${MYSQL_PORT_3306_TCP_ADDR}:${MYSQL_PORT_3306_TCP_PORT}';
$db[0]['user'] = '${MYSQL_USER}';
$db[0]['password'] = '${MYSQL_PASSWORD}';
$db[0]['database'] = '${MYSQL_DATABASE}';
define('_DATABASECON', serialize($db));
EOF
fi

exec "$@"
