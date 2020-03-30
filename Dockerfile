FROM amd64/ubuntu:latest

MAINTAINER Emil Moe

# ADD SOURCES
RUN add-apt-repository universe
RUN add-apt-repository ppa:certbot/certbot

# MAKE SURE EVERYTHING IS UP TO DATE
RUN apt-get update
RUN apt-get upgrade -yqq

# INSTALL DEPENDENCIES
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install nodejs apache2 php7.2 php7.2-mysql \
    php7.2-bcmath php7.2-bz2 php7.2-mbstring php7.2-zip \
    php7.2-common php7.2-xml php7.2-cli php7.2-curl git \
    unzip curl php-imagick composer software-properties-common \
    certbot python-certbot-apache -yqq

# ENABLE APACHE MODS
RUN a2enmod rewrite

# FOLDER PERMISSIONS
RUN mkdir -p /var/www/html
RUN rm /var/www/html/*
RUN chown www-data:www-data /var/www/html
RUN git clone https://${GIT_USER}:${GIT_TOKEN}@${GIT_REPO} -b ${GIT_BRANCH} /var/www/html

# CONFIG FILES
COPY ./vhost.conf /etc/apache2/sites-enabled/${DOMAIN}.conf
RUN certbot --apache --quiet --redirect --domain ${DOMAIN}

# SCHEDULES
RUN (crontab -u www-data -l 2>/dev/null; echo "* * * * * php /var/www/html/artisan schedule:run") | crontab -

# RUN curl https://raw.github.com/timkay/aws/master/aws -o aws --cacert /etc/ssl/certs/ca-certificates.crt
# RUN update-ca-certificates

# WORKDIR
VOLUME ["/var/www/html"]

# PREPARING FOR LAUNCH
WORKDIR /var/www/html

EXPOSE 80 443

ENTRYPOINT sudo /usr/sbin/apache2ctl -D FOREGROUND 
