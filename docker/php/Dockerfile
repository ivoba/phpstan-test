FROM composer:2.1 AS composer
FROM phusion/baseimage:18.04-1.0.0

ENV BUILD 11.10.2021
ENV HOME /root
ENV TIMEZONE Europe/Berlin
ENV APP_ROOT app
ENV COMPOSER_HOME /var/www
ENV DEBIAN_FRONTEND noninteractive

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

RUN add-apt-repository -y ppa:ondrej/php \
  && apt-get update \
  && apt-get install -y --force-yes git zip tar curl wget php8.0-cli php8.0-fpm php8.0-mysql\
               php8.0-gd php8.0-zip php8.0-intl php8.0-pgsql php8.0-sqlite php8.0-curl\
               php8.0-imap php8.0-tidy php-pear php8.0-dev php8.0-xsl php8.0-mbstring\
               libxml2-dev unzip libz-dev libicu-dev nano libmagickwand-dev imagemagick\
               php8.0-soap php8.0-opcache ffmpeg sox \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/8.0/fpm/php-fpm.conf

COPY zz_docker.conf /etc/php/8.0/fpm/pool.d/zz_docker.conf

COPY --from=composer /usr/bin/composer /usr/bin/composer

# Add github and bitbucket keys to known hosts
RUN ssh-keyscan -t rsa github.com 2>&1 >> /root/.ssh/known_hosts \
 && ssh-keyscan -t rsa bitbucket.org 2>&1 >> /root/.ssh/known_hosts

# Install imagick PHP Extension
RUN pecl channel-update pecl.php.net \
 && pecl install imagick \
 && echo extension=imagick.so > /etc/php/8.0/mods-available/imagick.ini \
 && ln -s /etc/php/8.0/mods-available/imagick.ini /etc/php/8.0/fpm/conf.d/20-imagick.ini \
 && ln -s /etc/php/8.0/mods-available/imagick.ini /etc/php/8.0/cli/conf.d/20-imagick.ini

# xdebug
RUN pecl install xdebug \
 && echo "zend_extension=/usr/lib/php/20200930/xdebug.so" > /etc/php/8.0/mods-available/xdebug.ini \
 && sed -i '1 a xdebug.max_nesting_level=1200' /etc/php/8.0/mods-available/xdebug.ini \
 && sed -i '1 a xdebug.discover_client_host=1' /etc/php/8.0/mods-available/xdebug.ini \
 && sed -i '1 a xdebug.start_with_request=trigger' /etc/php/8.0/mods-available/xdebug.ini \
 && sed -i '1 a xdebug.mode=debug' /etc/php/8.0/mods-available/xdebug.ini \
 && sed -i '1 a xdebug.client_port=9000' /etc/php/8.0/mods-available/xdebug.ini \
 && ln -s /etc/php/8.0/mods-available/xdebug.ini /etc/php/8.0/fpm/conf.d/20-xdebug.ini \
 && ln -s /etc/php/8.0/mods-available/xdebug.ini /etc/php/8.0/cli/conf.d/20-xdebug.ini

RUN pecl install apcu \
 && echo "extension=apcu.so" > /etc/php/8.0/mods-available/apcu.ini \
 && ln -s /etc/php/8.0/mods-available/apcu.ini /etc/php/8.0/fpm/conf.d/20-apcu.ini \
 && ln -s /etc/php/8.0/mods-available/apcu.ini /etc/php/8.0/cli/conf.d/20-apcu.ini

RUN pecl install rar \
 && echo "extension=rar.so" > /etc/php/8.0/mods-available/rar.ini \
 && ln -s /etc/php/8.0/mods-available/rar.ini /etc/php/8.0/fpm/conf.d/20-rar.ini \
 && ln -s /etc/php/8.0/mods-available/rar.ini /etc/php/8.0/cli/conf.d/20-rar.ini

# Setup Timezone
RUN echo $TIMEZONE | tee /etc/timezone \
 && dpkg-reconfigure -f noninteractive tzdata

ADD phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x /etc/service/phpfpm/run
RUN mkdir /run/php/

ENV HOME /var/www

RUN usermod -s /bin/bash www-data \
  && usermod -d /var/www/ www-data \
  && usermod -u 1000 www-data -s /bin/bash

WORKDIR $APP_ROOT
