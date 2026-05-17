#!/bin/bash
# 01-frontend.sh - Install and set up the frontend component of the Roboshop application
# This script will: frontend component of the Roboshop application

echo "configuring the frontend component of the Roboshop application"

#i want to run this script as root user
ID=$(id -u)
component="frontend"
logfile="/tmp/${component}.log"

if [ $ID -ne 0 ]; then
  echo -e "\e[31mThis script must be run as root or sudo user. Please run the script with sudo or as root.\e[0m"
  echo -e "\e[33mex: sudo bash $0 or # bash $0\e[0m"
  exit 1
fi


echo "disabling the default nginx configuration"
dnf module disable nginx -y &>> $logfile

stat() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32msuccess\e[0m"
  else
    echo -e "\e[31mfailure\e[0m"
    exit 2
  fi
}

stat $?


echo "Enabling installing 24 version nginx"
dnf module enable nginx:1.24 -y &>> $logfile
stat $?


echo "installing nginx"
dnf install nginx -y &>> $logfile
stat $?


echo "downloading the $component code"
curl -L -o /tmp/$component.zip "https://stan-robotshop.s3.amazonaws.com/$component-v3.zip" &>> $logfile

stat $?

echo "performing cleanup: removing old content from nginx html directory"
cd /usr/share/nginx/html
rm -rf /usr/share/nginx/html/* &>> $logfile

stat $?

echo "extracting the $component code"
unzip -o /tmp/$component.zip -d /usr/share/nginx/html &>> $logfile
stat $?


echo -n "configuring the $component nginx configuration file"
if [ -f /usr/share/nginx/html/nginx.conf ]; then
  mv /usr/share/nginx/html/nginx.conf /etc/nginx/default.d/roboshop.conf &>> $logfile
  stat $?
else
  echo -e "\e[31mnginx.conf not found in extracted code. Skipping custom config.\e[0m" | tee -a $logfile
  # Optionally, you can exit here if config is required:
  # exit 3
fi
cp nginx.conf /etc/nginx/default.d/roboshop.conf &>> $logfile
stat $? 

echo "starting $component nginx service"
systemctl enable nginx &>> $logfile
systemctl start nginx &>> $logfile
stat $?

echo -e "\e[32m$component component of the Roboshop application has been set up successfully\e[0m"
