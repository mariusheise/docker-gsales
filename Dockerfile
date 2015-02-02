FROM		debian:jessie
MAINTAINER	Julian Haupt <julian.haupt@hauptmedia.de>

ENV		GSALES_VERSION gsales2-rev1082-php54

# install dependencies
RUN		apt-get update -qq && \
    		apt-get install -y --no-install-recommends curl apache2 php5 php5-mysql && \
		apt-get clean autoclean && \
		apt-get autoremove --yes && \ 
		rm -rf /var/lib/{apt,dpkg,cache,log}/

# install gsales
RUN		mkdir /var/www/gsales && \
		curl -L --silent http://www.gsales.de/download/${GSALES_VERSION}.tar.gz | tar -xz --strip=1 -C /var/www/gsales && \
		sed -i -e"s/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/gsales/" /etc/apache2/sites-available/000-default.conf

EXPOSE		80	

VOLUME		["/var/log/apache2", "/var/www/gsales/DATA"]
CMD		["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
