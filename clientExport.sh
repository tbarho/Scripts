#!/bin/bash

PROJECT_ID=$1

echo "'PROJECT_ID=$PROJECT_ID'"

function usage {
    echo "$0  [project id] ";
    exit 1;
}

if [ $# != 1 ]; then
    usage
fi

#Run all the checks

#Check if the database exists.  If it doesn't, exit.
DBS=`mysql -uroot -p"Redrooster8" -Bse 'show databases'|egrep -v 'information_schema|mysql'`
RESULT=1
for db in $DBS;
do
        if [ "$db" == $PROJECT_ID ]; then
                RESULT=0;
        fi
done
if [ $RESULT -eq 1 ]; then
	echo "Database does not exist.  Can't export.  Exiting....";
	exit;
else
	echo "Database was found.  Proceeding....";
fi



#Check if the project exists in SVN.  If it doesn't, exit.
svn ls file:///var/svn/client_sites/$PROJECT_ID &> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ]; then
        echo "SVN repo for $PROJECT_ID was found. Proceeding...."
else
        echo "SVN repo for $PROJECT_ID does not exists. Exiting..."
	exit;
fi

# Now, assuming we have found an SVN repo, and we have found the database we move forward

# First we need to create a temporary directory to house the export
echo "Creating the temp directory for $PROJECT_ID export...."
#mkdir /var/www/tmp_$PROJECT_ID

# Then we need to export the site files from SVN
echo "Exporting file:///var/svn/client_sites/$PROJECT_ID/trunk to /var/www/tmp_$PROJECT_ID/$PROJECT_ID..."
svn export -q file:///var/svn/client_sites/$PROJECT_ID/trunk /var/www/tmp_$PROJECT_ID

# NOTE:  Temporarily, I have added template files to svn for exporting.  This is not a smart long term solution, however, in the essence of time, this is much faster than learning regex

# Now need to remove the config file and replace it with a templated one - this should not happen long term
echo "Removing the old _config.php file..."
rm -f /var/www/tmp_$PROJECT_ID/mysite/_config.php

echo "Adding the new config file...."
svn export -q file:///var/svn/Templates/_config.php /var/www/tmp_$PROJECT_ID/mysite/_config.php

# Next we remove the silverstripe install files, and add our own install file
echo "Removing the SilverStripe documentation files, and adding the SiteSprocket install file...."
rm -f /var/www/tmp_$PROJECT_ID/ChangeLog
rm -f /var/www/tmp_$PROJECT_ID/COPYING
rm -f /var/www/tmp_$PROJECT_ID/INSTALL
rm -f /var/www/tmp_$PROJECT_ID/UPGRADING

svn export -q file:///var/svn/Templates/install.txt /var/www/tmp_$PROJECT_ID/install.txt

# Now we need to add all the stuff that doesn't exist in the install, because it's a dev site (cms, googlesitemaps, sapphire, index.php)
echo "Adding cms, googlesitemaps, sapphire, index.php to the export...."
svn export -q file:///var/svn/Core2.4.1/trunk/cms /var/www/tmp_$PROJECT_ID/cms
svn export -q file:///var/svn/Core2.4.1/trunk/googlesitemaps /var/www/tmp_$PROJECT_ID/googlesitemaps
svn export -q file:///var/svn/Core2.4.1/trunk/sapphire /var/www/tmp_$PROJECT_ID/sapphire
svn export -q file:///var/svn/Core2.4.1/trunk/index.php /var/www/tmp_$PROJECT_ID/index.php

# The last thing we add is the database script to the root of the site
echo "Adding the database file to the export...."
mysqldump -u root -p"Redrooster8" "$PROJECT_ID" > "/var/www/tmp_$PROJECT_ID/$PROJECT_ID.sql"

# Now we have our complete package ready to be tarred up . . . 
echo "Tarring up the site to /var/www/tmp_$PROJECT_ID/$PROJECT_ID.tar.gz...."
tar -czpf /var/www/tmp_$PROJECT_ID/$PROJECT_ID.deploy.tar.gz -C /var/www tmp_$PROJECT_ID

# Then added to SVN backups with "export" in the name
echo "Adding the file to SVN so it can be downloaded...."
svn import -q /var/www/tmp_$PROJECT_ID/$PROJECT_ID.deploy.tar.gz file:///var/svn/client_sites/$PROJECT_ID/backup/$PROJECT_ID.deploy.tar.gz -m "SITE DEPLOYED"

# Now we clean up, simply by removing the temp directory
echo "Cleanin up...."
rm -rf /var/www/tmp_$PROJECT_ID

# And we're done!
echo "And we're done!  File is ready to download from SVN."


