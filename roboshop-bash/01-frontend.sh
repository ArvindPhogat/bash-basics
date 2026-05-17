#!/bin/bash
# 01-frontend.sh - Install and set up the frontend component of the Roboshop application
# This script will: frontend component of the Roboshop application

echo "configuring the frontend component of the Roboshop application"

#i want to run this script as root user
ID=$(id -u)

if [ $ID -ne 0 ]; then
  echo "This script must be run as root or sudo user. Please run the script with sudo or as root."
  echo "ex: sudo bash $0 or # bash $0"
  exit 1
fi


echo "disabling the default nginx configuration"
dnf module disable nginx -y

echo "Enabling installing 24 version nginx"
dnf module enable nginx:1.24 -y

echo "installing nginx"
dnf install nginx -y

