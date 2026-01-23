#!/bin/bash
 
 
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
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

dnf module disable redis -y &>>$LOG_FILE
dnf module enable redis:7 -y &>>$LOG_FILE

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing redis"

sed -i -e 's/127.0.0.0/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redid/redis.conf
VALIDATE $? "changing config"

systemctl enable redis &>>$LOG_FILE
systemctl start redis 
VALIDATE $? "start redis"

systemctl status redis