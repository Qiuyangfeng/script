#!/bin/bash
# 安装常用软件
sudo apt update && sudo apt install -y gcc make openjdk-8-jre-headless
# 配置内核参数
echo "vm.overcommit_memory = 1" | sudo tee -a /etc/sysctl.conf
echo "net.core.somaxconn= 1024" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
#关闭THP内存管理
touch -f disable-THP.service
cat > disable-THP.service <<EOF
[Unit]
Description=Disable Transparent Huge Pages (THP)
DefaultDependencies=no
After=sysinit.target local-fs.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo never | tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null'

[Install]
WantedBy=basic.target
EOF
sudo mkdir -p /usr/lib/systemd/system/ && sudo mv -f disable-THP.service /usr/lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start disable-THP.service && sudo systemctl enable disable-THP.service
# 下载安装配置redis
wget http://download.redis.io/releases/redis-5.0.5.tar.gz && tar -zxvf redis-5.0.5.tar.gz
sudo mkdir -p /opt/redis && sudo chown $USER:$USER /opt/redis
cd $PWD/redis-5.0.5/ && make MALLOC=libc PREFIX=/opt/redis install
cd ~/ && touch redis.conf redis.service
cat > redis.conf <<EOF
#redis
bind 0.0.0.0
port 6379
daemonize yes
dbfilename "dump.rdb"
dir "/opt/redis/"
logfile "/opt/redis/redis.log"
#cluster-enabled yes
#cluster-config-file "/opt/redis/nodes.conf"
#cluster-node-timeout 15000
appendonly yes
appendfilename "appendonly.aof"
EOF
mv  -f redis.conf /opt/redis/
# 让systemd管理redis server
sudo mkdir -p /usr/lib/systemd/system
cat > redis.service <<EOF
[Unit]
Description=Redis Server

[Service]
Type=forking
WorkingDirectory=/opt/redis
ExecStart=/opt/redis/bin/redis-server /opt/redis/redis.conf

[Install]
WantedBy=multi-user.target
EOF
sudo mv -f redis.service /usr/lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start redis.service && sudo systemctl enable redis.service
rm ~/redis-5.0.5.tar.gz && rm -rf ~/redis-5.0.5/
echo "redis server is on 0.0.0.0:6379"
