#!/bin/bash
# 04-redis.sh - Install and set up the redis component of the Roboshop application
# This script will: redis component of the Roboshop application

echo "configuring the redis component of the Roboshop application"

ID=$(id -u)
COMPONENT="redis"
LOG="/tmp/${COMPONENT}.log"
version="7.0"

if [ $ID -ne 0 ]; then
  echo -e "\e[31m This script must be run as root or sudo user. Please run the script with sudo or as root. \e[0m"
  echo -e "\e[33mex: sudo bash $0 or # bash $0\e[0m"
  exit 1
fi

echo "configuring the redis ${COMPONENT} of the Roboshop application"

stat() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32m success \e[0m"
  else
    echo -e "\e[31m failure \e[0m"
    exit 2
  fi
}

echo -n "disabling redis for ${COMPONENT} in progress..."
dnf module disable redis -y &>> $LOG
stat $?

echo -n "enabling redis for ${COMPONENT} ${version} in progress..."
dnf module enable redis:7 -y &>> $LOG
stat $?

echo -n "installing redis for ${COMPONENT} in progress..."
dnf install redis -y &>> $LOG
stat $?     

echo -n "configuring redis for ${COMPONENT} to listen on all interfaces in progress..."
sed -ie 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf &>> $LOG
stat $?

echo -n "configuring redis for ${COMPONENT} to listen on all interfaces in progress..."
sed -ie 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>> $LOG    
stat $?

echo -n "starting $component service in progress..."
systemctl enable $COMPONENT &>> $LOG
systemctl start $COMPONENT &>> $LOG
stat $?
-script

echo -e "\e[32m ${COMPONENT} setup completed successfully! \e[0m"
