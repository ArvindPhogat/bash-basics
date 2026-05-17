#!/bin/bash
# 01-frontend.sh - Install and set up the frontend component of the Roboshop application
# This script will: frontend component of the Roboshop application

echo "configuring the frontend component of the Roboshop application"

echo "disabling the default nginx configuration"
dnf module disable nginx -y

echo "Enabling installing 24 version nginx"
dnf module enable nginx:1.24 -y

echo "installing nginx"
dnf install nginx -y

