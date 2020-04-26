#!/bin/bash
#获取前一天的时间YESTERDAY
YESTERDAY=$(date +%Y-%m-%d --date='-1 day')
LOGPATH=/tmp/rsync.log
echo $YESTERDAY > $LOGPATH
Mail () {
echo -e "\n$MESSAGE" | mail -s "机构录音同步进度报告-$YESTERDAY" \
  -S smtp="172.16.1.236" \
  -S smtp-auth-user="alarm@cnwansun.com" \
  -S smtp-auth-password="123qwe!@#" \
  -S from="alarm@cnwansun.com" \
  -S smtp-auth=login \
  -a $LOGPATH \
   qiuyangfeng@cnwansun.com
}

MESSAGE_PATH=/tmp/message
#本服务器同步路径BAKPATH和机构个数TOTAL(也就是执行任务的次数)
BAKPATH=/recording
TOTAL=$(cat /home/ws/callcenter-ipaddress | wc -l)
echo > $MESSAGE_PATH

#从home/ws/callcenter-ipaddress取得机构名AGENCY和ip地址ADDRESS
multi_rsync() {
  AGENCY=$(cat /home/ws/callcenter-ipaddress | awk 'NR==LINE {print $1}' LINE=$1)
  ADDRESS=$(cat /home/ws/callcenter-ipaddress | awk 'NR==LINE {print $2}' LINE=$1)
  /usr/bin/rsync -az --password-file=/etc/rsync.password rsync@$ADDRESS::recording/* $BAKPATH/$AGENCY &> $LOGPATH
  if [[ $? == 0 ]]
  then
    echo "机构: $AGENCY 服务器: $ADDRESS 时间: $YESTERDAY 录音同步成功完成！" >> $MESSAGE_PATH
  else
    echo -e "\n机构: $AGENCY 服务器: $ADDRESS 时间: $YESTERDAY 录音同步异常，请检查同步状态！！！\n" >> $MESSAGE_PATH
  fi

}

#设置线程数和生成并绑定文件描述符
num=4
pipefile="/tmp/rsync_$$.tmp"
mkfifo $pipefile
exec 12<>$pipefile

for i in `seq $num`
do
    echo "" >&12 &
done

for j in `seq $TOTAL`
do
    read -u12
    {
      multi_rsync $j
      echo "" >&12
    } &
done
wait
rm $pipefile
MESSAGE=$(cat /tmp/message)
Mail
