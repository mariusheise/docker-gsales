FROM       mariusheise/php-web:7.3-apache-sapi
MAINTAINER Marius Heise <marius.heise@ensivion.com>

ENV     EMPTY_STRING ""
ENV     PHP_VERSION 7.3
ENV     GSALES_REVISION 1154
ENV     GSALES_HOME /var/www/gsales
ENV     RUN_SCRIPTS 1

# Install wget
RUN     apt-get update -qq && \
        apt-get install -y \
        wget && \
        apt-get clean autoclean && \
        apt-get autoremove --yes && \
        rm -rf /var/lib/{apt,dpkg,cache,log}/

# Install ioncube loader
RUN     cd /tmp \
        && wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -qO - | tar xfvz - \
        && mkdir /usr/local/ioncube/ \
        && mv ioncube/ioncube_loader_lin_${PHP_VERSION}.so /usr/local/ioncube/ \
        && rm -rf ioncube \
        && echo "zend_extension=/usr/local/ioncube/ioncube_loader_lin_${PHP_VERSION}.so" > /etc/php/7.3/cli/php.ini \
        && echo "zend_extension=/usr/local/ioncube/ioncube_loader_lin_${PHP_VERSION}.so" > /etc/php/7.3/apache2/php.ini

# redirect apache logs
RUN     find /etc/apache2 -type f -exec sed -ri ' \
        s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
        s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
        ' '{}' ';'

# install gsales conf
COPY    gsales.conf /etc/apache2/sites-available/gsales.conf

# Download g*Sales
SHELL   ["/bin/bash", "-c"]
RUN     mkdir -p ${GSALES_HOME} \
        && export GSALES_DOWNLOAD_URL=https://www.gsales.de/download/gsales2-rev${GSALES_REVISION}-php${PHP_VERSION/./$EMPTY_STRING}.tar.gz \
        && echo ${GSALES_DOWNLOAD_URL} \
        && wget ${GSALES_DOWNLOAD_URL} -qO - | tar --strip=1 -xzC ${GSALES_HOME}
SHELL   ["/bin/sh", "-c"]

# Enable and add sites
RUN     a2dissite 000-default && \
        a2ensite gsales

EXPOSE  80

COPY    docker-entrypoint.sh /usr/local/sbin/docker-entrypoint.sh


ENTRYPOINT ["/usr/local/sbin/docker-entrypoint.sh"]
VOLUME     ["${GSALES_HOME}/DATA"]
CMD        ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
