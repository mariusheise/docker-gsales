FROM		debian:wheezy
MAINTAINER	Julian Haupt <julian.haupt@hauptmedia.de>

ENV		GSALES_VERSION gsales2-rev1082-php54
ENV		ZENDGUARDLOADER_VERSION ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64

# install dependencies
RUN		apt-get update -qq && \
    		apt-get install -y --no-install-recommends curl apache2 php5 php5-mysql && \
		apt-get clean autoclean && \
		apt-get autoremove --yes && \ 
		rm -rf /var/lib/{apt,dpkg,cache,log}/

# integrate ZendGuardLoader
RUN		curl -L --silent http://downloads.zend.com/guard/6.0.0/${ZENDGUARDLOADER_VERSION}.tar.gz | tar -xz --strip=1 -C /tmp && \
		cp /tmp/php-5.4.x/ZendGuardLoader.so /usr/lib/php5/20100525/ && \
		echo "extension=ZendGuardLoader.so\n" >/etc/php5/conf.d/00-zendguardloader.ini

# install gsales
RUN		mkdir /var/www/gsales && \
		curl -L --silent http://www.gsales.de/download/${GSALES_VERSION}.tar.gz | tar -xz --strip=1 -C /var/www/gsales && \
		sed -i -e"s/\/var\/www/\/var\/www\/gsales/" /etc/apache2/sites-available/default

EXPOSE		80	

VOLUME		["/var/log/apache2", "/var/www/gsales/DATA"]
CMD		["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
