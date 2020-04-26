#!/bin/sh

DUMP=/opt/mongodb/bin/mongodump #mongodump备份文件执行路径
OUT_DIR=/home/ws/mongodb_bak/tmp #临时备份目录
TAR_DIR=/home/ws/mongodb_bak/list #备份存放路径
DATE=`date +%Y%m%d%H%M` #获取当前系统时间
DAYS=6 #DAYS=7代表删除7天前的备份，即只保留最近7天的备份
TAR_BAK="mongodb_bak_$DATE.tar.gz" #最终保存的数据库备份文件名
cd $OUT_DIR #切换到临时备份目录
rm -rf $OUT_DIR/* #删除临时备份文件
mkdir -p $OUT_DIR/$DATE #创建临时备份目录
$DUMP -h 172.16.1.162:27200 -o $OUT_DIR/$DATE #备份全部数据库
tar -zcvf $TAR_DIR/$TAR_BAK $OUT_DIR/$DATE #压缩为.tar.gz格式并存到备份路径
find $TAR_DIR/ -mtime +$DAYS -delete #删除7天前的备份文件
