#!/bin/bash
# 安装基础环境
sudo apt update && sudo apt install -y libcurl4 gcc

# 下载mongodb二级制包
curl -O https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1604-4.0.10.tgz
tar -zxvf mongodb-linux-x86_64-ubuntu1604-4.0.10.tgz && sudo mv -f mongodb-linux-x86_64-ubuntu1604-4.0.10 /opt/mongodb
mkdir -p /opt/mongodb/{data,log} && touch -f {mongod.conf,mongodb.service,disable-THP.service}
# mongodb的配置文件
cat > mongod.conf << EOF
# 系统日志
systemLog:
  destination: file
  logAppend: true
  logRotate: rename
  path: /opt/mongodb/log/mongod.log
# 慢查询日志
operationProfiling:
  mode: slowOp
  slowOpThresholdMs: 100
# 阈值，默认值为100，单位毫秒
# 数据库存储路径和缓存
storage:
  dbPath: /opt/mongodb/data
  journal:
    enabled: true
  engine: wiredTiger 
  wiredTiger:
    engineConfig:
      cacheSizeGB: 1
# mongod进程pid
processManagement:
  fork: true
  pidFilePath: /opt/mongodb/mongod.pid
# 可访问地址和端口
net:
  port: 27017
  bindIp: 0.0.0.0
# 用户名认证
#security:
#  authorization: enabled
# 副本集群名称
#replication:
#  replSetName: repl
# 分片
#sharding:
#  clusterRole: shardsvr
EOF
# mongodb的sysytemd启动文件
cat > mongodb.service << EOF
[Unit]
Description=Mongodb-cluster Server

[Service]
Type=forking
WorkingDirectory=/opt/mongodb/
ExecStart=/opt/mongodb/bin/mongod --config /opt/mongodb/mongod.conf

[Install]
WantedBy=multi-user.target
EOF
# 关闭THP内存管理
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
# 把配置各个文件放到对应的位置
sudo mkdir -p /usr/lib/systemd/system/ && sudo mv -f {mongodb.service,disable-THP.service} /usr/lib/systemd/system/
mv -f mongod.conf /opt/mongodb/ && sudo systemctl daemon-reload
sudo systemctl start mongodb.service && sudo systemctl enable mongodb.service
sudo systemctl start disable-THP.service && sudo systemctl enable disable-THP.service
# 把mongodb程序加入环境变量
echo 'export MONGODB_HOME=/opt/mongodb' >> ~/.bashrc
echo 'export PATH=$PATH:$MONGODB_HOME/bin' >> ~/.bashrc
source ~/.bashrc
