#!/bin/bash
# 安装常用软件
sudo apt update && sudo apt install -y gcc make openjdk-8-jre-headless

#安装tomcat8
wget https://mirror.bit.edu.cn/apache/tomcat/tomcat-8/v8.5.53/bin/apache-tomcat-8.5.53-fulldocs.tar.gz && tar -zxvf apache-tomcat-8.5.53.tar.gz
sudo mv $PWD/apache-tomcat-8.5.53/ /opt/tomcat8/ && rm ~/apache-tomcat-8.5.53.tar.gz
