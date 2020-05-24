#!/bin/bash

ECHOWRAPPER="==============================================\n\n%s\n\n==============================================\n"

printf $ECHOWRAPPER "Make beautiful VIM"
apt-get -y install vim
echo "colorscheme desert" | sudo tee /etc/vim/vimrc.local > /dev/null

mkdir -p /var/www
mkdir -m 0777 /vagrant
ln -s /vagrant /var/www/project
chmod 0777 /var/www/project

#GIT
printf $ECHOWRAPPER "Installing GIT"
apt-get install -y git

#MySQL-Database - percona flavor
printf $ECHOWRAPPER "Installing Percona Mysql"
export DEBIAN_FRONTEND=noninteractive
wget https://repo.percona.com/apt/percona-release_0.1-3.$(lsb_release -sc)_all.deb
dpkg -i percona-release_0.1-3.$(lsb_release -sc)_all.deb
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8507EFA5
apt-get update
apt-get install -y percona-server-server

#Nginx - But a current version please
printf $ECHOWRAPPER "Installing NGINX"
cat <<EOT >> /etc/apt/sources.list.d/nginx.list
deb http://nginx.org/packages/mainline/ubuntu trusty nginx
deb-src http://nginx.org/packages/mainline/ubuntu trusty nginx
EOT

wget http://nginx.org/packages/keys/nginx_signing.key
cat nginx_signing.key | sudo apt-key add -
rm nginx_signing.key

apt-get update
apt-get install -y nginx
##Lets run as www-data, as every good webserver should do
sed -i 's~user  nginx;~user  www-data;~'  /etc/nginx/nginx.conf

usermod -a -G www-data vagrant

#PHP
printf $ECHOWRAPPER "Installing PHP"
apt-get install -y php-fpm php-cli php-mysql php-imagick php-gd php-xdebug php-pear php-dev php-mcrypt php-curl php-pdo

# PHP konfigurieren
printf $ECHOWRAPPER "Configuring PHP"
cd ~
wget https://github.com/frickelbruder/php-ini-setter/releases/download/1.1.2/php-ini-setter.phar
chmod a+x php-ini-setter.phar
./php-ini-setter.phar --name short_open_tag --value On --file /etc/php/7.0/apache2/php.ini
./php-ini-setter.phar --name memory_limit --value 512M --file /etc/php/7.0/apache2/php.ini
./php-ini-setter.phar --name log_errors --value On --file /etc/php/7.0/apache2/php.ini
./php-ini-setter.phar --name error_log --value /var/log/php_errors.log --file /etc/php/7.0/apache2/php.ini
./php-ini-setter.phar --name max_execution_time --value 120 --file /etc/php/7.0/apache2/php.ini

./php-ini-setter.phar --name short_open_tag --value On --file /etc/php/7.0/cli/php.ini
./php-ini-setter.phar --name memory_limit --value 512M --file /etc/php/7.0/cli/php.ini
./php-ini-setter.phar --name log_errors --value On --file /etc/php/7.0/cli/php.ini
./php-ini-setter.phar --name error_log --value /var/log/php_errors.log --file /etc/php/7.0/cli/php.ini
./php-ini-setter.phar --name max_execution_time --value 120 --file /etc/php/7.0/cli/php.ini

touch /var/log/php_errors.log
chmod a+r /var/log/php_errors.log

##PHPDEVELOPMENT

###PHPUNIT
printf $ECHOWRAPPER "Installing Phpunit"
wget https://phar.phpunit.de/phpunit-5.7.9.phar
mv phpunit-5.7.9.phar /usr/local/bin/phpunit.phar
chmod a+x /usr/local/bin/phpunit.phar
ln -s /usr/local/bin/phpunit.phar /usr/local/bin/phpunit

###COMPOSER
printf $ECHOWRAPPER "Installing Composer"
php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer.phar
ln -s /usr/local/bin/composer.phar /usr/local/bin/composer
php5dismod -s cli xdebug

###PHPAB
printf $ECHOWRAPPER "Installing phpab"
wget https://github.com/theseer/Autoload/releases/download/1.25.9/phpab-1.25.9.phar
mv phpab-1.25.9.phar /usr/local/bin/phpab.phar
chmod a+x /usr/local/bin/phpab.phar
ln -s /usr/local/bin/phpab.phar /usr/local/bin/phpab

#phpmyadmin
printf $ECHOWRAPPER "Installing PHPMyAdmin"
printf $ECHOWRAPPER "Setting PHPMyAdmin debconf settings"
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean false '
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-reinstall boolean false '
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect '
debconf-set-selections <<< 'phpmyadmin phpmyadmin/internal/skip-preseed boolean true '
printf $ECHOWRAPPER "Doing the install"
sudo apt-get --no-install-recommends install -y phpmyadmin
sed -i 's~ //\(.*AllowNoPassword.*\)~\1~g' /etc/phpmyadmin/config.inc.php
sed -i "s~'cookie';~'config';~1" /etc/phpmyadmin/config.inc.php
sed -i "s~= \$dbuser;~= 'root';~1" /etc/phpmyadmin/config.inc.php
sed -i "s~= \$dbpass;~= '';~1" /etc/phpmyadmin/config.inc.php
sed -i "s~= \$dbserver;~= '127.0.0.1';~1" /etc/phpmyadmin/config.inc.php

#Ruby (required for compass)
printf $ECHOWRAPPER "Installing Ruby"
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm requirements
rvm install ruby-head
rvm use ruby-head --default

usermod -a -G rvm vagrant
echo ". /etc/profile.d/rvm.sh" >> ~/.bashrc
echo ". /etc/profile.d/rvm.sh" >> ~vagrant/.bashrc

#Compass
printf $ECHOWRAPPER "Installing Compass"
gem install compass

#NodeJS/NPM
printf $ECHOWRAPPER "Installing Node/NPM"
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
apt-get install -y nodejs

#Bower
printf $ECHOWRAPPER "Installing Bower"
#npm install -g bower
