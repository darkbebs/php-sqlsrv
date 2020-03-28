FROM ubuntu:18.04

MAINTAINER Cleiton Ribeiro (big.dark@gmail.com)

ARG DEBIAN_FRONTEND=noninteractive

# update package list
RUN apt-get update && \
    apt-get install -y apache2 && \
    ACCEPT_EULA=Y apt-get -y install php7.2 mcrypt php-mbstring php-pear php7.2-dev php7.2-xml unixodbc-dev libmcrypt-dev gpg && \
    apt-get install -y libapache2-mod-php7.2 curl && \
    apt-get update && \
    apt-get install -y apt-transport-https && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    apt install -y libcurl3 && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql mssql-tools && \
    pecl install sqlsrv && \
    echo "extension=sqlsrv.so" >> /etc/php/7.2/cli/conf.d/10-pdo.ini && \
    pecl install pdo_sqlsrv && \
    echo "extension=pdo_sqlsrv.so" >> /etc/php/7.2/apache2/conf.d/10-pdo.ini && \
    echo 'yes' |  pecl install mcrypt && \
    echo "extension=mcrypt.so" >> /etc/php/7.2/apache2/php.ini && \
    echo "extension=/usr/lib/php/20170718/sqlsrv.so" >> /etc/php/7.2/apache2/conf.d/10-pdo.ini && \
    echo "extension=/usr/lib/php/20170718/pdo_sqlsrv.so" >> /etc/php/7.2/apache2/conf.d/10-pdo.ini && \
    echo "extension=/usr/lib/php/20170718/sqlsrv.so" >> /etc/php/7.2/cli/conf.d/10-pdo.ini && \
    echo "extension=/usr/lib/php/20170718/pdo_sqlsrv.so" >> /etc/php/7.2/cli/conf.d/10-pdo.ini && \
    echo "error_log = /dev/stderr" >> /etc/php/7.2/apache2/php.ini && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc && \
    apt-get install -y locales && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && \
    sed -i "/post_max_size = .*/c\post_max_size = 1000M" /etc/php/7.2/apache2/php.ini && \
    sed -i "/max_execution_time = .*/c\max_execution_time = 300" /etc/php/7.2/apache2/php.ini && \
    sed -i "/upload_max_filesize = .*/c\upload_max_filesize = 1000M" /etc/php/7.2/apache2/php.ini && \
    sed -i "/memory_limit = .*/c\memory_limit = 512M" /etc/php/7.2/apache2/php.ini && \
    sed -i "/display_errors = .*/c\display_errors = On" /etc/php/7.2/apache2/php.ini 


EXPOSE 80

WORKDIR /var/www/html/

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]