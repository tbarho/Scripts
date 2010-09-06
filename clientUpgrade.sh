#!/bin/bash

PROJECT_ID=$1
fileDate="`date +%Y-%m-%d-%H-%M-%S`"

echo "'PROJECT_ID=$PROJECT_ID'"

function usage {
    echo "$0  [project id] ";
    exit 1;
}

if [ $# != 1 ]; then
    usage
fi

#Run all the checks


#To Do: Check if the database exists, exit if it doesnt

#To Do: Check if the project exists in SVN, exit if it doesnt
svn ls file:///var/svn/client_sites/$PROJECT_ID &> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ]; then
        echo "SVN repo for $PROJECT_ID already exists. Proceeding..."
else
        echo "SVN repo for $PROJECT_ID does not exist. Exiting..."
	exit;
fi


#To Do: Check if the project exists in var/www, if it doesnt, exit
if [ -e "/var/www/sites/$PROJECT_ID" ]; then
        echo "Found a directory named $PROJECT_ID in /var/www/sites.  Proceeding..."
else
        echo "$PROJECT_ID does not exist in /var/www/sites.  Exiting..."
fi

# Back up the site, and import to SVN /backup folder
echo "Backing up the site and importing SVN backup folder...."

# Create a temp directory
mkdir /var/www/tmp_$PROJECT_ID


# Dump the db to temp
mysqldump -u root -p"Redrooster8" $PROJECT_ID > /var/www/tmp_$PROJECT_ID/$PROJECT_ID.$fileDate.sql

# TAR the exported site to temp
tar -czpf /var/www/tmp_$PROJECT_ID/$PROJECT_ID.$fileDate.tar.gz -C /var/www/sites $PROJECT_ID

# Import to SVN
svn import "/var/www/tmp_$PROJECT_ID/$PROJECT_ID.$fileDate.tar.gz" file:///var/svn/client_sites/$PROJECT_ID/backup/$PROJECT_ID.$fileDate.tar.gz -m "BACKUP - TAR backup of site on $fileDate"
svn import "/var/www/tmp_$PROJECT_ID/$PROJECT_ID.$fileDate.sql" file:///var/svn/client_sites/$PROJECT_ID/backup/$PROJECT_ID.$fileDate.sql -m "BACKUP - SQL dump of site on $fileDate"
 

# Drop the temp directory
rm -rf /var/www/tmp_$PROJECT_ID


# Dropping jsparty for old versions of SilverStripe
svn ls file:///var/svn/client_sites/$PROJECT_ID/trunk/jsparty &> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ]; then
	echo "Folder /jsparty exists in SVN.  Removing..."
	svn delete file:///var/svn/client_sites/$PROJECT_ID/trunk/jsparty -m "DELETE - Deleting /jsParty for upgrade from 2.3"
fi


#Drop sapphire, cms, googlesitemaps, and index.php
svn ls file:///var/svn/client_sites/$PROJECT_ID/trunk/sapphire &> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ]; then
        echo "Folder /sapphire exists in SVN.  Removing..."
        svn delete file:///var/svn/client_sites/$PROJECT_ID/trunk/sapphire -m "DELETE - Deleting /sapphire for upgrade"
fi
svn ls file:///var/svn/client_sites/$PROJECT_ID/trunk/cms &> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ]; then
        echo "Folder /cms exists in SVN.  Removing..."
        svn delete file:///var/svn/client_sites/$PROJECT_ID/trunk/cms -m "DELETE - Deleting /cms for upgrade"
fi
svn ls file:///var/svn/client_sites/$PROJECT_ID/trunk/googlesitemaps &> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ]; then
        echo "Folder /googlesitemaps exists in SVN.  Removing..."
        svn delete file:///var/svn/client_sites/$PROJECT_ID/trunk/googlesitemaps -m "DELETE - Deleting /googlesitemaps for upgrade"
fi
svn ls file:///var/svn/client_sites/$PROJECT_ID/trunk/index.php &> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ]; then
        echo "File /index.php exists in SVN.  Removing..."
        svn delete file:///var/svn/client_sites/$PROJECT_ID/trunk/index.php -m "DELETE - Deleting /index.php for upgrade"
fi



# Check for old versions of modules dataobject_manager, userforms, swfupload

declare -a ALL_MODULES
declare -a CLIENT_MODULES

# Create temp folder for storing upgrades
echo "Creating temp folder /var/www/tmp/$PROJECT_ID"
mkdir /var/www/tmp/$PROJECT_ID
mkdir /var/www/tmp/$PROJECT_ID/modules

ALL_MODULES=( ${ALL_MODULES[@]} $(
                svn ls file:///var/svn/modules | { 
                        while read i; do
                                echo ${i%/}     
                        done
                }       
        ))

echo "ALL_MODULES: ${ALL_MODULES[*]}"

CLIENT_MODULES=( ${CLIENT_MODULES[@]} $(
                svn ls file:///var/svn/client_sites/$PROJECT_ID/trunk |grep "/" | {
                        while read i; do
                                echo ${i%/}
                        done
                }
        ))

echo "CLIENT_MODULES: ${CLIENT_MODULES[*]}"

for i in ${ALL_MODULES[*]}
do
        for j in ${CLIENT_MODULES[*]}
                do
                        if [ "$i" == "$j" ]; then
                                echo "Upgrading: $j Module"
				
				# Drop the module in Client SVN
				svn delete file:///var/svn/client_sites/$PROJECT_ID/trunk/$j -m "UPGRADE: $j Module"

				# Export upgrade to temp folder
				svn export -q file:///var/svn/modules/$j/trunk /var/www/tmp/$PROJECT_ID/modules/$j

				# Import the upgrade to the client project
				svn import --force -q /var/www/tmp/$PROJECT_ID/modules/$j file:///var/svn/client_sites/$PROJECT_ID/trunk/$j -m "UPGRADE: $j Module"

                        fi
                done
done

# Drop the temp folder
echo "Dropping the temp folder /var/www/tmp/$PROJECT_ID"
rm -rf /var/www/tmp/$PROJECT_ID

# Now we have everything we need in SVN, so drop the web root
echo "Dropping /var/www/sites/$PROJECT_ID..."
rm -rf /var/www/sites/$PROJECT_ID


# Export the upgraded project from SVN
echo "Export the the project from SVN...."
svn export -q file:///var/svn/client_sites/$PROJECT_ID/trunk /var/www/sites/$PROJECT_ID

#Add the sym links to core folders
echo "Adding the symbolic links to the new core...."
ln -s /var/www/Core2.4.1/sapphire/ /var/www/sites/$PROJECT_ID/sapphire
ln -s /var/www/Core2.4.1/cms/ /var/www/sites/$PROJECT_ID/cms
ln -s /var/www/Core2.4.1/googlesitemaps/ /var/www/sites/$PROJECT_ID/googlesitemaps
ln -s /var/www/Core2.4.1/index.php /var/www/sites/$PROJECT_ID/index.php


echo "Done.  Ready for dev/build."











