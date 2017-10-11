sudo su
# ルートフォルダ作成
mkdir public
# selinux 無効化
sed -i -e "s/SELINUXTYPE=targeted/SELINUXTYPE=disabled/" /etc/selinux/config
setenforce 0
# iptables
/sbin/service iptables stop
/sbin/chkconfig iptables off
# apache
yum -y install httpd
/etc/init.d/httpd start
# EPELとRemiリポジトリを追加
yum -y install epel-release
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
# php 7.1
yum -y remove php-*
yum -y install --enablerepo=remi,remi-php71 php php-devel php-mbstring php-mcrypt php-gd php-xml php-intl php-pear php-mysql
# mod_ssl
yum -y install mod_ssl
# 各種confファイルの設置
ln -sfb /vagrant/vagrant/config/apache/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf
ln -sfb /vagrant/vagrant/config/php.ini /etc/php.ini
# 再起動
/etc/init.d/httpd restart
/sbin/chkconfig httpd on
# 不要ファイル削除
rm -rf /var/www/cgi-bin
rm -rf /var/www/html
rm -rf /var/www/error
rm -rf /var/www/icons
# WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
sudo -u vagrant -i -- wp core download --locale=ja --path=/var/www/
# DBのインストール
rpm -Uvh http://dev.mysql.com/get/mysql57-community-release-el6-7.noarch.rpm
yum -y install mysql-community-server
# DB設定
cp -f /vagrant/vagrant/config/apache/etc/my.cnf /etc/my.cnf
chmod 644 /etc/my.cnf
service mysqld start --skip-grant-tables
mysql << EOS
use mysql;
UPDATE user SET authentication_string=password('root') WHERE user='root';
CREATE DATABASE wordpress;
flush privileges;
EOS
# DB再起動
service mysqld restart
chkconfig mysqld on
