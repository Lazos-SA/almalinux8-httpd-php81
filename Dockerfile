FROM almalinux:8.6
MAINTAINER Flavio Rojas Acuña <flavio.rojas@lazos.cl>
ENV container docker

# Install Apache
RUN dnf -y update \
RUN dnf -y install httpd httpd-tools

# Install REMI Repo
RUN dnf -y install epel-release \
 && dnf -y install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm \
 && dnf config-manager --set-enabled powertools

# Install Supervisor
RUN dnf -y install supervisor
COPY ./supervisord.conf /etc/supervisord.conf

# Enable REMI Repo and REMI-PHP81
RUN dnf -y module reset php \
 && dnf -y module enable php:remi-8.1

# Install PHP and PHP Utilities
RUN dnf -y install php php-fpm php-common php-cli php-pear php-gd php-imap php-ldap php-mysqlnd php-pgsql php-mbstring php-soap php-xml php-pecl-apcu \
    php-xmlrpc php-json php-intl php-mcrypt php-pecl-mcrypt php-bcmath php-process php-gmp php-pdo php-jsonlint php-pecl-zip php-pecl-http composer \
# Install common libraries and tools required/useful for Web Apps 
 && dnf -y install ImageMagick GraphicsMagick ghostscript gcc gcc-c++ zlib-devel unoconv

RUN dnf clean all

# Update Apache Configuration
RUN sed -E -i -e '/<Directory "\/var\/www\/html">/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
RUN sed -E -i -e 's/DirectoryIndex (.*)$/DirectoryIndex index.php \1/g' /etc/httpd/conf/httpd.conf

# Update php-fpm Configuration
RUN mkdir /run/php-fpm
RUN sed -E -i -e 's/;listen.owner = nobody/listen.owner = apache/g' /etc/php-fpm.d/www.conf
RUN sed -E -i -e 's/;listen.group = nobody/listen.group = apache/g' /etc/php-fpm.d/www.conf
RUN sed -E -i -e 's/listen.acl_users = (.*)$/;listen.acl_users = \1/g' /etc/php-fpm.d/www.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n"]
