FROM		hauptmedia/php-web:5.6-apache-sapi
MAINTAINER	Julian Haupt <julian.haupt@hauptmedia.de>

ENV		GSALES_VERSION gsales2-rev1121-php56
ENV		GSALES_HOME /var/www/gsales

# enable zend_guard_loader
RUN		php5dismod opcache && php5enmod zend_guard_loader

# redirect apache logs
RUN find /etc/apache2 -type f -exec sed -ri ' \
    s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
    s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
' '{}' ';'

# install gsales
COPY		gsales.conf /etc/apache2/sites-available/gsales.conf

RUN		mkdir ${GSALES_HOME} && \
		curl -L --silent http://www.gsales.de/download/${GSALES_VERSION}.tar.gz | tar -xz --strip=1 -C ${GSALES_HOME} && \
		a2dissite 000-default && \
		a2ensite gsales

EXPOSE		80	

COPY		docker-entrypoint.sh	/usr/local/sbin/docker-entrypoint.sh


ENTRYPOINT	["/usr/local/sbin/docker-entrypoint.sh"]
VOLUME		["${GSALES_HOME}/DATA"]
CMD		["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
