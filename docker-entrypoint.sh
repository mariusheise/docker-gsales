#!/bin/bash
set -e

if [ -e  ${GSALES_HOME}/lib/inc.cfg.php ]; then
	exec "$@"
	exit 0
fi


cp ${GSALES_HOME}/lib/inc.cfg.dist.php ${GSALES_HOME}/lib/inc.cfg.php

if [ -n "$MYSQL_NAME" ]; then
	MYSQL_HOST=${MYSQL_PORT_3306_TCP_ADDR}:${MYSQL_PORT_3306_TCP_PORT}

	if [ -z "$MYSQL_PASSWORD" ]; then
		MYSQL_PASSWORD=`pwgen -c -n -1 12`
	fi

	if [ -z "$MYSQL_USER" ]; then
		MYSQL_USER=gsales
	fi
	
	if [ -z "$MYSQL_DATABASE" ]; then
		MYSQL_DATABASE=gsales
	fi

	rc=$(mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h${MYSQL_PORT_3306_TCP_ADDR} -P ${MYSQL_PORT_3306_TCP_PORT} ${MYSQL_DATABASE} -e exit >/dev/null 2>&1; echo $?)
	
	if [ $rc -ne 0 ]; then
		if [ -n "$MYSQL_ENV_MYSQL_ROOT_PASSWORD" ]; then
			#try to create user & database
			echo "Creating MySQL user ${MYSQL_USER} and database ${MYSQL_DATABASE} on ${MYSQL_HOST}..."

			TMPFILE=/tmp/$$.sql
                	echo "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';" >$TMPFILE
			echo "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;" >>$TMPFILE
                	echo "GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;" >>$TMPFILE
			echo "FLUSH PRIVILEGES;" >>$TMPFILE

			rc=$(mysql -uroot -p${MYSQL_ENV_MYSQL_ROOT_PASSWORD} -h${MYSQL_PORT_3306_TCP_ADDR} -P ${MYSQL_PORT_3306_TCP_PORT} -e exit >/dev/null 2>&1 < $TMPFILE; echo $?)

			rm $TMPFILE

			if [ $rc -ne 0 ]; then
				echo Could not create database on ${MYSQL_HOST} 1>&2
				exit 1
			fi
		
		else
			echo "Could not use mysql database (host: ${MYSQL_HOST})" 1>&2
			exit 1
		fi

	fi

	cat >>$GSALES_HOME/lib/inc.cfg.php <<-EOF
<?php
\$db = array();
\$db[0]['host'] = '${MYSQL_HOST}';
\$db[0]['user'] = '${MYSQL_USER}';
\$db[0]['password'] = '${MYSQL_PASSWORD}';
\$db[0]['database'] = '${MYSQL_DATABASE}';
define('_DATABASECON', serialize(\$db));
EOF
fi

chown -R www-data:www-data ${GSALES_HOME}/lib/inc.cfg.php
chmod 600 ${GSALES_HOME}/lib/inc.cfg.php

exec "$@"

