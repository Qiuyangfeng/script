#!/bin/bash
# ubuntu
# 下载安装配置启动mysql-5.7(ubuntu16.04-18.04)
# 自动配置mysql默认编码为utf-8,不区分大小写,root密码123456 ,可以从其他地方登陆
sudo apt update && sudo apt install -y mysql-server-5.7
MYSQLUSEER=$(sudo cat /etc/mysql/debian.cnf|grep -m 1 user|cut -d= -f2|sed 's/ //g')
MYPASSWD=$(sudo cat /etc/mysql/debian.cnf|grep -m 1 password|cut -d= -f2|sed 's/ //g')
echo "default-character-set = utf8"|sudo tee -a /etc/mysql/conf.d/mysql.cnf
sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
echo "lower_case_table_names=1" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
mysql -u $MYSQLUSEER --password=$MYPASSWD -e "use mysql;update user set authentication_string=PASSWORD('123456') where user='root';update user set plugin='mysql_native_password';flush privileges;"
mysql -u $MYSQLUSEER --password=$MYPASSWD -e "use mysql;update user set host='%' where user='root';flush privileges;"
sudo systemctl restart mysql.service && sudo systemctl enable mysql.service
sudo systemctl status mysql.service
echo "Mysql-5.7 is running on 0.0.0.0:3306"
echo "User: root"
echo "Password: 123456"
