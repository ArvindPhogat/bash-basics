#!/bin/bash
# 01-frontend.sh - Install and set up the frontend component of the Roboshop application
# This script will: frontend component of the Roboshop application

echo "configuring the frontend component of the Roboshop application"

#i want to run this script as root user
ID=$(id -u)
component="frontend"
logfile="/tmp/${component}.log"

if [ $ID -ne 0 ]; then
  echo "This script must be run as root or sudo user. Please run the script with sudo or as root."
  echo "ex: sudo bash $0 or # bash $0"
  exit 1
fi


echo "disabling the default nginx configuration"
dnf module disable nginx -y &>> $logfile

if [ $? -eq 0 ]; then
  echo "success"
else
  echo "failure"
  exit 2
fi

echo "Enabling installing 24 version nginx"
dnf module enable nginx:1.24 -y &>> $logfile
if [ $? -eq 0 ]; then
  echo "success"
else
  echo "failure"
  exit 2
fi
echo "installing nginx"
dnf install nginx -y &>> $logfile
if [ $? -eq 0 ]; then
  echo "success"
else
  echo "failure"
  exit 2
fi

echo "downloading the $component code"
curl -L -o /tmp/$component.zip "https://stan-robotshop.s3.amazonaws.com/$component-v3.zip"

echo "performing cleanup: removing old content from nginx html directory"
cd /usr/share/nginx/html
rm -rf * &>> $logfile

echo "extracting the $component code"
unzip -o /tmp/$component.zip -d /usr/share/nginx/html &>> $logfile
if [ $? -eq 0 ]; then
  echo "success"
else
  echo "failure"
  exit 2
fi

echo "starting $component nginx service"
systemctl enable nginx &>> $logfile
systemctl start nginx &>> $logfile
if [ $? -eq 0 ]; then
  echo "success"
else
  echo "failure"
  exit 2
fi

echo "$component component of the Roboshop application has been set up successfully"
