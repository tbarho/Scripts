#!/bin/bash


#ToDo:

#Check to make sure you really wanna do this

echo "Do you really want to create a db backup and deploy the live site again?"
read confirm

if [ "$confirm" != "Y" ]; then
	echo "Ok.  Goodbye.";
	exit;
fi


echo "Moving on then...."

#Create the file name, for timestamp purposes
fileDate="`date +%Y-%m-%d-%H-%M-%S`"
fileName="sitesprocket_live.$fileDate.sql"
echo "The fileName is $fileName"


#Put up "Under Construction Page"
echo "Putting up the construction page...."


#Dump existing database to named file (with date)
echo "Dumping the database...."
mysqldump -uroot -p"Redrooster8" sitesprocket_live > /tmp/db_backup_tmp/$fileName


#Add the db file to svn repo for _live site
echo "Importing the Database to SVN...."
svn import /tmp/db_backup_tmp/$fileName file:///var/svn/db_backup_SiteSprocket/trunk/$fileName -m "IMPORT - Database backup"


#Delete the tmp db backup file
echo "Removing the temporary file...."
rm -f /tmp/db_backup_tmp/$fileName


#Delete the existing web root
echo "Deleting the web root...."
rm -rf /var/www/sitesprocket


#Export the current build to the web root
echo "Exporting from SVN to web root...."
svn export file:///var/svn/SiteSprocket/trunk /var/www/sitesprocket


#Run a wget to rebuild database; return success / fail
echo "Building the database...."
/usr/bin/wget -O /var/www/sitesprocket/builds/build-verification-$fileDate.html http://www.sitesprocket.com/dev/build?flush=1 2>&1
echo "Response was $?"


