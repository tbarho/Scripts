#/bin/bash


PROJECT_ID=$1
MYSQL_PWD=$2

echo "'PROJECT_ID=$PROJECT_ID'"

function usage {
    echo "$0  [project id] [mysql pwd]";
    exit 1;
}

if [ $# != 2 ]; then
    usage
fi

if [! mysql -u root --password=MYSQL_PWD]; then
    echo "Your MySQL Password was bad.";
    exit 1;
fi

#Build the scaffolding for the repo

mkdir /tmp/tmp_$PROJECT_ID
mkdir /tmp/tmp_$PROJECT_ID/branches
mkdir /tmp/tmp_$PROJECT_ID/tags
mkdir /tmp/tmp_$PROJECT_ID/trunk



#Copy the files from the latest built Core

cp -r /var/www/Core2.4.1/assets /tmp/tmp_$PROJECT_ID/trunk/assets 
cp -r /var/www/Core2.4.1/mysite /tmp/tmp_$PROJECT_ID/trunk/mysite 
cp -r /var/www/Core2.4.1/themes /tmp/tmp_$PROJECT_ID/trunk/themes 
cp -r /var/www/Core2.4.1/.htaccess /tmp/tmp_$PROJECT_ID/trunk/.htaccess



#Set the database in the _config.php file with sed

rm /tmp/tmp_$PROJECT_ID/trunk/mysite/_config.php
sed "s/{PREVIEW_NAME}/$PROJECT_ID/g" /var/www/Core2.4.1/mysite/_config.php > /tmp/tmp_$PROJECT_ID/trunk/mysite/_config.php



#Import the new Project into SVN

svn import /tmp/tmp_$PROJECT_ID file:///var/svn/client_sites/$PROJECT_ID -m "Initial Import of Client Project $PROJECT_ID"


#Delete the temp directory

rm -rf /tmp/tmp_$PROJECT_ID



#Create the database

echo "Dropping old database"
mysql -e"DROP DATABASE IF EXISTS $PROJECT_ID;" -u root -p"Redrooster8"
echo "Create database"
mysql -e"CREATE DATABASE $PROJECT_ID;" -u root -p"Redrooster8"



#Export the project from SVN to the web root

svn export file:///var/svn/client_sites/$PROJECT_ID/trunk /var/www/sites/$PROJECT_ID



#Symbolic links to Core

ln -s /var/www/Core2.4.1/sapphire/ /var/www/sites/$PROJECT_ID/sapphire 
ln -s /var/www/Core2.4.1/cms/ /var/www/sites/$PROJECT_ID/cms 
ln -s /var/www/Core2.4.1/googlesitemaps/ /var/www/sites/$PROJECT_ID/googlesitemaps 
ln -s /var/www/Core2.4.1/index.php /var/www/sites/$PROJECT_ID/index.php



#Run a wget to build the database

/usr/bin/wget -O /var/www/sites/"$PROJECT_ID"/build-verification.html http://sites.sitesprocket.com/"$PROJECT_ID"/dev/build?flush=1 2>&1






