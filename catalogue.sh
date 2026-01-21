#!/bin/bash
 
 set -euo pipefail

 trap 'echo "there is an error in $LINENO, Command is: $BASH_COMMAND"' ERR
 
USERID=$( id -u )

echo "Script started executed at: $(date) "
if [ $USERID -ne 0 ]; then
    echo "error:: plese run this script with root privelege"
    exit 1
fi

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.shivv-aws.fun
LOGS_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e " $2 is..$R FAILURE $N"
    else
        echo -e " $2 is ..$G SUCCESS $N"
    fi
}

dnf module disable nodejs -y
VALIDATE $? "Disbaling node:js"

dnf module enable nodejs:20 -y   
VALIDATE $? "enable nodejs:20"

dnf install nodejs -y
VALIDATE $? "installing nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
else
    echo -e "user already exists ....$Y SKIPPING $N"
fi

mkdir -p /app

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
cd /app
rm -rf /app/* 
unzip /tmp/catalogue.zip

npm install &>>$LOGS_FILE
cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service 

systemctl daemon-reload

systemctl enable catalogue &>>$LOGS_FILE 

echo -e "catalogue application setup .... $G SUCCESS $N"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOGS_FILE

INDEX=$(mongosh mongodb.shivv-aws.fun --quiet --eval "db.getMongo().getDBNames().indexof('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOGS_FILE
else
    echo -e "catalogue products already loaded.... $Y skipping $N"
fi

systemctl restart catalogue 

echo -e "Loading products and restarting catalogue .. $G success $N"