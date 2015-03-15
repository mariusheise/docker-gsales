FROM		debian:wheezy
MAINTAINER	Julian Haupt <julian.haupt@hauptmedia.de>

ENV		GSALES_VERSION gsales2-rev1091-php54
ENV		ZENDGUARDLOADER_VERSION ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64

ENV		GSALES_HOME /var/www/gsales
ENV		DEBIAN_FRONTEND noninteractive

# install dependencies
RUN		apt-get update -qq && \
    		apt-get install -y --no-install-recommends curl apache2 php5 php5-mysql pwgen mysql-client && \
		apt-get clean autoclean && \
		apt-get autoremove --yes && \ 
		rm -rf /var/lib/{apt,dpkg,cache,log}/

# redirect apache logs
RUN find /etc/apache2 -type f -exec sed -ri ' \
    s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
    s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
' '{}' ';'

# integrate ZendGuardLoader
RUN		curl -L --silent http://downloads.zend.com/guard/6.0.0/${ZENDGUARDLOADER_VERSION}.tar.gz | tar -xz --strip=1 -C /tmp && \
		cp /tmp/php-5.4.x/ZendGuardLoader.so /usr/lib/php5/20100525/ && \
		echo "extension=ZendGuardLoader.so\n" >/etc/php5/conf.d/00-zendguardloader.ini && \
		rm -rf /tmp/*

# install gsales
COPY		gsales /etc/apache2/sites-available/gsales
RUN		mkdir ${GSALES_HOME} && \
		curl -L --silent http://www.gsales.de/download/${GSALES_VERSION}.tar.gz | tar -xz --strip=1 -C ${GSALES_HOME} && \
		a2dissite default && \
		a2ensite gsales

EXPOSE		80	

COPY		docker-entrypoint.sh	/usr/local/sbin/docker-entrypoint.sh


ENTRYPOINT	["/usr/local/sbin/docker-entrypoint.sh"]
VOLUME		["${GSALES_HOME}/DATA"]
CMD		["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
