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

#Run all the checks



#Check if the DB password is good.  If not, exit.
mysql -u root -p$MYSQL_PWD -e"show databases;" &> /dev/null
RESULT=$?
if [ $RESULT -eq 1 ]; then
	echo "Password was wrong. Exiting."
	exit;
fi

#Check if the database exists.  If it does, exit.
DBS=`mysql -uroot -p$MYSQL_PWD -Bse 'show databases'|egrep -v 'information_schema|mysql'`
for db in $DBS;
do
	if [ "$db" == $PROJECT_ID ]; then
		echo "Database exists";
		exit;
	fi
done



#Check if the project exists in SVN.  If it does, exit.
svn ls file:///var/svn/client_sites/$PROJECT_ID &> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ]; then
	echo "SVN repo for $PROJECT_ID already exists. Exiting..."
	exit;
else
	echo "SVN repo for $PROJECT_ID does notexists. Proceeding..."
fi




#Check if the file exists in /var/www/sites.  If it does, exit.
if [ -e "/var/www/sites/$PROJECT_ID" ]; then
	echo "There is already a directory named $PROJECT_ID in /var/www/sites.  Exiting..."
	exit;
else
	echo "$PROJECT_ID does not exist in /var/www/sites.  Proceeding..."
fi


#If all the checks have passed, proceed with the site creation



#Build the scaffolding for the repo
mkdir /var/www/tmp_$PROJECT_ID
mkdir /var/www/tmp_$PROJECT_ID/branches
mkdir /var/www/tmp_$PROJECT_ID/tags
mkdir /var/www/tmp_$PROJECT_ID/trunk
mkdir /var/www/tmp_$PROJECT_ID/backup


#Copy the files from the latest built Core

cp -r /var/www/Core2.4.1/assets /var/www/tmp_$PROJECT_ID/trunk/assets 
cp -r /var/www/Core2.4.1/mysite /var/www/tmp_$PROJECT_ID/trunk/mysite 
cp -r /var/www/Core2.4.1/themes /var/www/tmp_$PROJECT_ID/trunk/themes 
cp -r /var/www/Core2.4.1/.htaccess /var/www/tmp_$PROJECT_ID/trunk/.htaccess



#Set the database in the _config.php file with sed

rm /var/www/tmp_$PROJECT_ID/trunk/mysite/_config.php
sed "s/{PREVIEW_NAME}/$PROJECT_ID/g" /var/www/Core2.4.1/mysite/_config.php > /var/www/tmp_$PROJECT_ID/trunk/mysite/_config.php



#Import the new Project into SVN

svn import /var/www/tmp_$PROJECT_ID file:///var/svn/client_sites/$PROJECT_ID -m "Initial Import of Client Project $PROJECT_ID"


#Delete the temp directory

rm -rf /var/www/tmp_$PROJECT_ID



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
echo "Response was $?"

