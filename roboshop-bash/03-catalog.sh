#!/bin/bash
# 03-catalog.sh - Install and set up the Catalogue component of the Roboshop application

ID=$(id -u)
COMPONENT="catalogue"
APPUSER="roboshop"
LOG="/tmp/${COMPONENT}.log"

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

echo "Installing Nodejs :"
dnf install nodejs -y &>> $LOG
stat $?

echo "Creating roboshop user account :"
id $APPUSER &>> $LOG
if [ $? -ne 0 ]; then
  useradd $APPUSER &>> $LOG
fi
stat $?

echo "Performing cleanup of $COMPONENT :"
rm -rf /app/ || true
stat $?

echo "Creating APP directory :"
[ -d /app ] || mkdir /app
stat $?

echo "Downloading the $COMPONENT app :"
curl -o /tmp/${COMPONENT}.zip https://stan-robotshop.s3.amazonaws.com/${COMPONENT}-v3.zip
stat $?

echo "Configuring systemd for $COMPONENT :"
if [ -f ${COMPONENT}.service ]; then
  cp ${COMPONENT}.service /etc/systemd/system/${COMPONENT}.service
  stat $?
else
  echo -e "\e[31mERROR: ${COMPONENT}.service file not found in $(pwd)!\e[0m"
  exit 3
fi

echo "Extracting the $COMPONENT app :"
unzip -o /tmp/${COMPONENT}.zip -d /app/ &>> $LOG
stat $?

echo "Generating $COMPONENT Artifacts :"
cd /app/
npm install &>> $LOG
stat $?

echo "Installing mongodb schema :"
dnf install mongosh -y &>> $LOG
if [ $? -ne 0 ]; then
  echo -e "\e[31mERROR: Failed to install mongosh. Check your repo configuration and network.\e[0m"
  exit 4
else
  stat $?
fi

echo "Injecting the schema :"
mongosh --host mongodb.robotshop.fun </app/db/master-data.js &>> $LOG
stat $?

echo "Reloading systemd and starting $COMPONENT service :"
systemctl daemon-reload
systemctl enable ${COMPONENT}
systemctl start ${COMPONENT}
stat $?

echo -e "\e[32m$COMPONENT setup completed successfully!\e[0m"