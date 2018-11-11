FROM ubuntu:16.04

# 環境変数設定
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
ENV LC_CTYPE ja_JP.UTF-8

# インストール
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    build-essential git ntp \
    openssl openssh-server libssl-dev \
    unzip vim curl wget build-essential \
    language-pack-ja-base language-pack-ja ibus-mozc \
    php php-cli php-pear php-fpm php-mysql php-curl php-gd php-mcrypt \
    php-intl php-imap php-tidy php-imagick php-mcrypt php-xdebug php-redis \
    php-zip php-mbstring \
    nginx

# 日本語環境設定
RUN update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja

# グループ・ユーザ
RUN \
  groupadd -g 1000 develop && \
  useradd -u 1000 -g 1000 -m -d /home/develop -s /bin/bash -c '共通開発者アカウント' develop && \
  echo 'develop:develop' | chpasswd && \
  gpasswd -a develop adm && \
  gpasswd -a develop sudo && \
  gpasswd -a develop www-data && \
  gpasswd -a develop staff && \
  gpasswd -a www-data develop && \
  gpasswd -a www-data staff

# 設定
## PHP
RUN \
  sed -i "s/;date.timezone =.*/date.timezone = Asia\/Tokyo/" /etc/php/7.0/fpm/php.ini && \
  sed -i "s/max_execution_time = .*/max_execution_time = 180/" /etc/php/7.0/cli/php.ini

### xDebug
ADD ./php7/xdebug.ini /etc/php/7.0/mods-available/xdebug.ini

### FPM
ADD ./php7/www.conf /etc/php/7.0/fpm/pool.d/www.conf
RUN \
  sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf && \
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini && \
  sed -i "s/session.save_handler = files/session.save_handler = redis/" /etc/php/7.0/fpm/php.ini

## nginx
ADD ./nginx/server.conf /etc/nginx/conf.d/server.conf

## Ntp
RUN cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

## composer入れる(2行目はバージョンによってハッシュ値が変わるので作成時の最新のものを入れるべき)
## => https://composer.github.io/pubkeys.html
RUN mkdir /app -p
WORKDIR /app
RUN php -r "readfile('https://getcomposer.org/installer');" >composer-setup.php ;\
php -r "if (hash_file('SHA384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" ;\
php composer-setup.php --filename=composer;\
php -r "unlink('composer-setup.php');" ;\
mv composer /usr/local/bin/composer
