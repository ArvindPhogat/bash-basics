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
dnf install mongodb-mongosh -y &>> $LOG

dnf install mongodb-mongosh -y &>> $LOG
if [ $? -ne 0 ] || ! command -v mongodb-mongosh &>/dev/null; then
  echo -e "\e[33mFalling back to mongosh tarball install...\e[0m"
  cd /tmp
  curl -s -O https://downloads.mongodb.com/compass/mongosh-2.0.1-linux-x64.tgz
  tar -xzf mongosh-2.0.1-linux-x64.tgz
  sudo mv mongosh-2.0.1-linux-x64/bin/mongosh /usr/local/bin/
  sudo chmod +x /usr/local/bin/mongosh
  if ! command -v mongosh &>/dev/null; then
    echo -e "\e[31mERROR: Failed to install mongosh by all methods.\e[0m"
    exit 4
  fi
  echo -e "\e[32mmongosh installed via tarball.\e[0m"
else
  stat $?
fi

echo "Injecting the schema :"
if command -v mongosh &>/dev/null; then
  mongosh --host mongodb.robotshop.fun </app/db/master-data.js &>> $LOG
  stat $?
elif command -v mongodb-mongosh &>/dev/null; then
  mongodb-mongosh --host mongodb.robotshop.fun </app/db/master-data.js &>> $LOG
  stat $?
else
  echo -e "\e[31mERROR: No mongosh client found for schema injection.\e[0m"
  exit 5
fi

echo "Reloading systemd and starting $COMPONENT service :"
systemctl daemon-reload
systemctl enable ${COMPONENT}
systemctl start ${COMPONENT}
stat $?

echo -e "\e[32m$COMPONENT setup completed successfully!\e[0m"