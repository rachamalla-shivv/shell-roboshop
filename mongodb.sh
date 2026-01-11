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
LOGS_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e " $2 is..$R FAILURE $N"
    else
        echo -e " $2 is ..$G SUCCESS $N"
    fi
}

cp mongo.repo /etc/yum.repod.d/mongo.repo
VALIDATE $? "adding mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "installing mongo"

systemctl enable mongodb
VALOIDATE $? "enable mongodb"

systemctl start mongodb
VALIDATE $? "starting mongodb"

systemctl restart mongod
VALIDATE $? "RESTART MONGODB"
