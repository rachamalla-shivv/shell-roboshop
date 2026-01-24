#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log
SCRIPT_DIR=$PWD
START_TIME=$(date +%s)
mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y  &>>$LOG_FILE
dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "enable node js"

dnf install nodejs -y  &>>$LOG_FILE
VALIDATE $? "install node js"

id roboshop  &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "cerating system user"
else
    echo "user already exist"
fi

mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "creating app dir"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip   &>>$LOG_FILE
cd /app 
rm -rf /app/*  &>>$LOG_FILE
VALIDATE $? "removing existing code"

unzip /tmp/user.zip  &>>$LOG_FILE
VALIDATE $? "unnzip code"

npm install  &>>$LOG_FILE 
VALIDATE $? "installing dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copy systemctl service"

systemctl daemon-reload
systemctl enable user &>>$LOG_FILE
VALIDATE $? "Enable user"

systemctl restart user
VALIDATE $? "Restarted user"