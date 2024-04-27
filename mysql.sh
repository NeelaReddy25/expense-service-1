#!/bin/bash

source ./common.sh

check_root

echo "Please enter DB password:"
read mysql_root_password

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MYSQL server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MYSQL"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting MYSQL"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE &>>$LOGFILE
# VALIDATE $? "MYSQL root password secure"

mysql -h db.neelareddy.store -u root -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MYSQL Root Password setup"
else
    echo -e "MYSQL Root password is already seutp...$Y SKIPPING $N"
fi          