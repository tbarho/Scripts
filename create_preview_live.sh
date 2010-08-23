#/bin/bash

PROJECT_ID=$1

echo "'PROJECT_ID=$PROJECT_ID'"

function usage {
    echo "$0  [project id]";
    exit 1;
}

if [ $# != 1 ]; then
    usage
fi



#Build the scaffolding for the repo

mkdir /tempProjects/$PROJECT_ID
mkdir /tempProjects/$PROJECT_ID/branches
mkdir /tempProjects/$PROJECT_ID/tags
mkdir /tempProjects/$PROJECT_ID/trunk



#Copy the files from the latest built Core

cp -r /var/www/Core2.4.1/assets /tempProjects/$PROJECT_ID/trunk/assets 
cp -r /var/www/Core2.4.1/mysite /tempProjects/$PROJECT_ID/trunk/mysite 
cp -r /var/www/Core2.4.1/themes /tempProjects/$PROJECT_ID/trunk/themes 
cp -r /var/www/Core2.4.1/.htaccess /tempProjects/$PROJECT_ID/trunk/.htaccess



#Set the database in the _config.php file with sed

rm /tempProjects/$PROJECT_ID/trunk/mysite/_config.php
sed "s/{PREVIEW_NAME}/$PROJECT_ID/g" /var/www/Core2.4.1/mysite/_config.php > /tempProjects/$PROJECT_ID/trunk/mysite/_config.php



#Import the new Project into SVN

svn import /tempProjects/$PROJECT_ID file:///var/svn/$PROJECT_ID -m "Initial Import of Client Project $PROJECT_ID"


#Delete the temp directory
rm -rf /tempProjects/$PROJECT_ID



#Create the database
echo "Dropping old database"
mysql -e"DROP DATABASE IF EXISTS $PROJECT_ID;" -u root -p"Redrooster8"
echo "Create database"
mysql -e"CREATE DATABASE $PROJECT_ID;" -u root -p"Redrooster8"



#Export the project from SVN to the web root
svn export file:///var/svn/$PROJECT_ID /var/www/html/$PROJECT_ID



#Symbolic links to Core
ln -s /var/www/Core2.4.1/sapphire/ /var/www/html/$PROJECT_ID/sapphire 
ln -s /var/www/cms/ /var/www/html/$PROJECT_ID/cms 
ln -s /var/www/Core2.4.1/googlesitemaps/ /var/www/html/$PROJECT_ID/googlesitemaps 
ln -s /var/www/Core2.4.1/index.php /var/www/html/$PROJECT_ID/index.php






