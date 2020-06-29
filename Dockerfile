FROM php:7.4.6-apache

COPY ./config/vhost.conf /etc/apache2/sites-available/000-default.conf

RUN set -eux; \
	apt-get update && apt-get install -y \
	libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        zlib1g-dev \
        libxml2-dev \
        libzip-dev \
	libgmp-dev \
	libonig-dev \
	libcurl4-openssl-dev \

        graphviz \
	git;

WORKDIR /tmp

RUN git clone https://github.com/jbboehr/php-psr.git
WORKDIR /tmp/php-psr
RUN phpize
RUN ./configure
RUN make
RUN make test
RUN make install

RUN docker-php-ext-install mbstring       
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install gmp
RUN docker-php-ext-install dom
RUN docker-php-ext-install intl
RUN docker-php-ext-install curl
RUN docker-php-ext-install zip

RUN pecl install mcrypt
RUN docker-php-ext-enable mcrypt

WORKDIR /tmp

RUN git clone --depth=1 "git://github.com/phalcon/cphalcon.git"
WORKDIR /tmp/cphalcon/build
RUN ./install

#INSTALL APCU
ARG APCU_VERSION=5.1.18
RUN pecl install apcu-${APCU_VERSION} && docker-php-ext-enable apcu
RUN echo "extension=apcu.so" > /usr/local/etc/php/php.ini
RUN echo "apc.enable_cli=1" > /usr/local/etc/php/php.ini
RUN echo "apc.enable=1" > /usr/local/etc/php/php.ini

RUN chown -R www-data:www-data /var/www/html && a2enmod rewrite && service apache2 restart
WORKDIR /var/www/html