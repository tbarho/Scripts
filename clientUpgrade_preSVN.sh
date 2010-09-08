#!/bin/bash

#Assuming we have the .sql dump and site files in a folder

#Pass in the existing location of the site files
importFile=$1

#Pass in the name of the client site (for svn and URL)
siteName=$2

#Make sure we have the vars, if not, exit
function usage {
	echo "$0 [ /path/to/import/file ] [ site name ]";
	exit;
}

if [ $# != 2 ]; then
	usage
fi

#Set a date for timestamping files that need it
date="`date +%m-%d-%Y-%H-%M-%S`"

#Check if the existing files exist, if they don't fail
if [ ! -e "$importFile" ]; then
	echo "Could not find $importFile.  Exiting..."
	exit;
else
	echo "$importFile exists.  Proceeding...."
fi 


#Check if the project exists in SVN, if it does, fail
svn ls file:///var/svn/$siteName &> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ]; then
	echo "SVN repo for $siteName already exists.  Exiting...."
	exit;
else
	echo "SVN repo for $siteName does not exist yet.  Proceeding..."
fi


#Check if the DB exists, if it does, fail
DBS=`mysql -uroot -p"Redrooster8" -Bse 'show databases'|egrep -v 'information_schema|mysql'`
for db in $DBS;
do
	if [ "$db" == $siteName ]; then
		echo "Database $db exists.  Exiting";
		exit;
	fi
done


#Check if the site already exists in WWW, if it does, fail
if [ -e "/var/www/sites/$siteName"  ]; then
	echo "There is already a directory named $siteName in /var/www/sites.  Exiting...."
	exit;
else
	echo "$siteName has room to exist in /var/www/sites.  Proceeding...."
fi

echo "All the checks passed.  Proceeding...."


#Create the folder structure for svn (trunk, branches, tags, build)
echo "Creating the folder structure for the new $siteName SVN project...."
mkdir /tmp/site_tmp/$siteName
mkdir /tmp/site_tmp/$siteName/trunk
mkdir /tmp/site_tmp/$siteName/branches
mkdir /tmp/site_tmp/$siteName/tags
mkdir /tmp/site_tmp/$siteName/build

#Move the tarball to the tmp folder
#echo "Moving $importFile to /tmp/site_tmp/$siteName/trunk/$siteName.tar.gz"
#mv "$importFile" /tmp/site_tmp/$siteName/trunk/"$siteName".tar.gz

#Extract the .tar.gz file to /tmp/site_tmp/$siteName/trunk
echo "Extracting $importFile to /tmp/site_tmp/$siteName/trunk....."
tar -zxvf "$importFile" -C"/tmp/site_tmp/$siteName/trunk"


#Move any .sql files into the build folder for SVN
echo "Moving .sql files from /trunk to /build...."
mv /tmp/site_tmp/$siteName/trunk/*.sql /tmp/site_tmp/$siteName/build

#Remove the folders that will be upgraded (the Core folders)
echo "Dropping the folders that need upgrading...."
rm -rf /tmp/site_tmp/$siteName/trunk/sapphire
rm -rf /tmp/site_tmp/$siteName/trunk/cms
rm -rf /tmp/site_tmp/$siteName/trunk/googlesitemaps
rm -rf /tmp/site_tmp/$siteName/trunk/index.php

#Remove and replace the config file to work with _ss_environment
echo "Updating the mysite/_config.php file...."
rm /tmp/site_tmp/$siteName/trunk/mysite/_config.php
sed "s/{PREVIEW_NAME}/$siteName/g" /var/www/Core2.4.1/mysite/_config.php > /tmp/site_tmp/$siteName/trunk/mysite/_config.php

#Do the SVN Import (we're not worrying about upgrading modules)
echo "Importing new client project $siteName to SVN...."
svn import /tmp/site_tmp/$siteName file:///var/svn/$siteName -m "IMPORT - Initial import of $siteName"

#Drop the temp site folder, don't drop the original yet, cause we still need the DB file
echo "Dropping temporary folders and import files...."
rm -rf /tmp/site_tmp/$siteName
#rm -rf $importFile

#Export the svn trunk to /var/www/sites
echo "Exporting from SVN...."
svn export file:///var/svn/$siteName/trunk /var/www/sites/$siteName

#Create the sym links to the new core
echo "Adding the symbolic links to the new core...."
ln -s /var/www/Core2.4.1/sapphire/ /var/www/sites/$siteName/sapphire
ln -s /var/www/Core2.4.1/cms/ /var/www/sites/$siteName/cms
ln -s /var/www/Core2.4.1/googlesitemaps/ /var/www/sites/$siteName/googlesitemaps
ln -s /var/www/Core2.4.1/index.php /var/www/sites/$siteName/index.php

#Create the database
#NOTE: the database with the old information will be imported at a later time.  This is helping to ensure a clean upgrade...maybe...
echo "Creating the new database...."
mysql -e"CREATE DATABASE $siteName;" -uroot -p"Redrooster8"

#Run a wget to build the new database, save the output to a build file
echo "Running wget to build the db...."
/usr/bin/wget -O /var/www/sites/"$siteName"/build-verification-$date.html http://sites.sitesprocket.com/"$siteName"/dev/build?flush=1 2>&1
echo "Response was $?"

#Commit build file to SVN
echo "Adding the build verification to SVN...."
svn import /var/www/sites/"$siteName"/build-verification-$date.html file:///var/svn/$siteName/build -m "BUILD - imported $date"

#Delete temp build file
echo "Dropping the temp build verfication file...."
rm -f /var/www/sites/"$siteName"/build-verification-$date.html

echo "Complete.  You should now be able to see a working copy of the site at http://sites.sitesprocket.com/$siteName."
