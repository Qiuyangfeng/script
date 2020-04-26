#!/bin/bash

# 选择结果,并执行对应的操作
choose()
{
read -p "(1).确认  (2).重设  (3).退出  请输入数字选择 > " CONFIRM
case $CONFIRM in
  1) if [ ! -z $NEWIP ] && [ ! -z $NEWGATEWAY ];then
          sudo sed -i "s/dhcp/static/" /etc/network/interfaces && echo "    address $NEWIP"|sudo tee -a /etc/network/interfaces
          echo "    netmask 24"|sudo tee -a /etc/network/interfaces && echo "    gateway $NEWGATEWAY"|sudo tee -a /etc/network/interfaces
	  echo "    dns-nameservers 172.16.1.2 223.6.6.6"|sudo tee -a /etc/network/interfaces && sudo timedatectl set-timezone Asia/Shanghai
          echo "$NEWIP callcenter-$A-$B"|sudo tee -a /etc/hosts && echo "callcenter-$A-$B"|sudo tee /etc/hostname && sudo reboot
     else
          echo -e "\n错误的IP地址或网关地址,请重新执行脚本！" && exit 1
     fi
     ;;
  2) echo " " && setIphost
     ;;
  3) exit
     ;;
  *) echo "Please choose 1-3 !" && choose
     exit 1
     ;;
esac
}

# 提示输入IP和网关地址
setIphost()
{
read -p "请输入你要配置本机的IP地址 > " NEWIP
read -p "请输入你要配置本机的网关地址 > " NEWGATEWAY
A=$(echo $NEWIP|cut -d. -f3)
B=$(echo $NEWIP|cut -d. -f4)
echo "请确认网络配置信息"
echo "IP: $NEWIP  网关: $NEWGATEWAY"
choose
}

setIphost
