#!/bin/bash

source ./common.sh

check_root

echo "Please enter DB password:"
read mysql_root_password

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodeje"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodeje"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating user expense"
else
    echo -e "Expense user already created...$Y SKIPPING $N" 
fi       

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted backend code"


npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/expense-service-1/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Deamon Reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Strating backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing MYSQL client"

mysql -h db.neelareddy.store -u root -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend"





