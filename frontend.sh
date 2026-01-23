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
SCRIPT_DIR=$PWD
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOGS_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e " $2 is..$R FAILURE $N"
    else
        echo -e " $2 is ..$G SUCCESS $N"
    fi
}

dnf module disable nginx -y &>>$LOG_FILE
dnf module enable nginx:1.24 -y &>>$LOG_FILE
dnf install nginx -y &>>$LOG_FILE

VALIDATE $? " installing nginx "

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx  &>>$LOG_FILE
VALIDATE $? "enabling systemctl"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? " removing user content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /usr/share/nginx/html &>>$LOG_FILE
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? " downloading and unzip the code"

rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "nginx config"
 
systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "restart nginx"