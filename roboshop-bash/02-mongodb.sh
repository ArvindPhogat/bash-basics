#!/bin/bash
# 02-mongodb.sh - Automated MongoDB 7.0 setup for Roboshop on RHEL 9

set -e

ID=$(id -u)
COMPONENT="mongodb"
LOG="/tmp/${COMPONENT}.log"

if [ $ID -ne 0 ]; then
  echo -e "\e[31mThis script must be run as root or sudo user.\e[0m"
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

MONGODB_REPO_SRC="$(pwd)/mongodb.repo"
MONGODB_REPO_DEST="/etc/yum.repos.d/mongodb.repo"
echo -n "Copying MongoDB repo file: "
if [ -f "$MONGODB_REPO_SRC" ]; then
  cp "$MONGODB_REPO_SRC" "$MONGODB_REPO_DEST" &>> $LOG
  stat $?
else
  echo -e "\e[31mERROR: Source MongoDB repo file not found at $MONGODB_REPO_SRC.\e[0m"
  exit 1
fi

echo -n "Installing MongoDB: "
dnf install -y mongodb-org &>> $LOG
stat $?

echo -n "Configuring mongod to listen on all interfaces: "
sed -i 's/^  bindIp:.*$/  bindIp: 0.0.0.0/' /etc/mongod.conf &>> $LOG
stat $?

echo -n "Enabling and starting mongod service: "
systemctl enable mongod &>> $LOG
systemctl start mongod &>> $LOG
stat $?

echo -e "\e[32mMongoDB setup completed successfully!\e[0m"
