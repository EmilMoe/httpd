FROM amd64/ubuntu:latest

MAINTAINER Emil Moe

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

RUN apt-get update
RUN apt-get -y upgrade

# INSTALL APACHE + PHP
RUN apt-get install -qq -y software-properties-common
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/apache2
RUN apt-get -qq update

RUN apt-get -qq -y install bash wget apache2 php7.2 curl php7.2-cli php7.2-mysql php7.2-curl git gnupg php7.2-mbstring php7.2-xml unzip sudo curl php7.2-zip cron php7.2-bcmath php-imagick composer
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get -qq -y install nodejs 
RUN apt-get -qq -y install libtool automake autoconf nasm libpng-dev make g++

RUN adduser local --disabled-password

RUN echo "local ALL = NOPASSWD: ALL" >> /etc/sudoers

RUN a2enmod rewrite

RUN mkdir -p /var/www/html
RUN rm /var/www/html/index.html
RUN chown local:www-data /var/www/html

COPY ./vhost.conf /etc/apache2/sites-enabled/001-docker.conf

RUN (crontab -l 2>/dev/null; echo "* * * * * php /var/www/html/artisan schedule:run") | crontab -

RUN curl https://raw.github.com/timkay/aws/master/aws -o aws --cacert /etc/ssl/certs/ca-certificates.crt
RUN update-ca-certificates

VOLUME ["/var/www/html"]

# PREPARING FOR LAUNCH
WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT sudo /usr/sbin/apache2ctl -D FOREGROUND 
