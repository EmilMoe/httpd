FROM amd64/ubuntu:latest

MAINTAINER Emil Moe

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

RUN apt-get -qq update && apt-get -qq -y upgrade
RUN apt-get install -qq -y software-properties-common
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/apache2
RUN apt-get -qq update

RUN apt-get -qq -y install apache2 php7.2 curl php7.2-cli php7.2-mysql php7.2-curl git gnupg php7.2-mbstring php7.2-xml unzip sudo curl php7.2-zip cron php7.2-bcmath
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get -qq -y install nodejs 
RUN apt-get -qq -y install libtool automake autoconf nasm libpng-dev make g++

RUN adduser local --disabled-password

RUN echo "local ALL = NOPASSWD: ALL" >> /etc/sudoers

RUN a2enmod rewrite

RUN mkdir -p /var/www/html
RUN rm /var/www/html/index.html
RUN chown local:www-data /var/www/html

COPY ./vhost.conf /etc/apache2/sites-enabled/001-docker.conf

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer
    
RUN (crontab -l 2>/dev/null; echo "* * * * * php /var/www/html/artisan schedule:run") | crontab -

VOLUME ["/var/www/html"]

WORKDIR /var/www/html

EXPOSE 80 9515 3000

ENTRYPOINT sudo /usr/sbin/apache2ctl -D FOREGROUND 
