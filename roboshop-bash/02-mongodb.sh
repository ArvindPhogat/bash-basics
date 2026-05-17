#!/bin/bash
# 02-mongodb.sh - Install and set up the MongoDB component of the Roboshop application
# This script will: MongoDB component of the Roboshop application

echo "configuring the MongoDB component of the Roboshop application"

ID=$(id -u)
component="mongodb"
logfile="/tmp/${component}.log"

if [ $ID -ne 0 ]; then
  echo -e "\e[31mThis script must be run as root or sudo user. Please run the script with sudo or as root.\e[0m"
  echo -e "\e[33mex: sudo bash $0 or # bash $0\e[0m"
  exit 1
fi

stat() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32msuccess\e[0m"
  else
    echo -e "\e[31mfailure\e[0m"
    exit 2
  fi
}

echo -n "configuring the MongoDB repository:"

cp /home/ec2-user/bash-basics/roboshop-bash/mongodb.repo /etc/yum.repos.d/mongodb.repo &>> $logfile
stat $?


# dnf install mongodb-org -y 
echo -n "installing $component:"
dnf install mongodb-org -y &>> $logfile
stat $?

echo -n "updating $component visibility:"
sed -ie 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $logfile



# systemctl enable mongod

echo -n "enabling $component service:"
systemctl enable mongod  
systemctl start mongod
stat $?
