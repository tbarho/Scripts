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
#Check if the database exists.  If it does, exit.
DBS=`mysql -uroot -p"Redrooster8" -Bse 'show databases'|egrep -v 'information_schema|mysql'`
DBE=1
for db in $DBS;
do
        if [ "$db" == $PROJECT_ID ]; then
                echo "Database exists.  Proceeding...."
		DBE=0
        fi
done

if [ $DBE != 0 ]; then
	echo "Database does not exist.  Exiting...."
	exit;
fi

#To Do: Check if the project exists in SVN, exit if it doesnt
svn ls file:///var/svn/client_sites/$PROJECT_ID &> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ]; then
        echo "SVN repo for $PROJECT_ID already exists. Proceeding..."
else
        echo "SVN repo for $PROJECT_ID does not exist. Exiting..."
        exit;
fi


# Back up the site, and import to SVN /backup folder
echo "Backing up the site and importing SVN backup folder...."

# Create a temp directory
mkdir /var/www/tmp_$PROJECT_ID


# Dump the db to temp
mysqldump -u root -p"Redrooster8" "$PROJECT_ID" > "/var/www/tmp_$PROJECT_ID/$PROJECT_ID.$fileDate.sql"

# TAR the exported site to temp
tar -czpf /var/www/tmp_$PROJECT_ID/$PROJECT_ID.$fileDate.tar.gz -C /var/www/sites $PROJECT_ID

# Import to SVN
svn import "/var/www/tmp_$PROJECT_ID/$PROJECT_ID.$fileDate.tar.gz" file:///var/svn/client_sites/$PROJECT_ID/backup/$PROJECT_ID.$fileDate.tar.gz -m "BACKUP - TAR backup of site on $fileDate"
svn import "/var/www/tmp_$PROJECT_ID/$PROJECT_ID.$fileDate.sql" file:///var/svn/client_sites/$PROJECT_ID/backup/$PROJECT_ID.$fileDate.sql -m "BACKUP - SQL dump of site on $fileDate"
 

# Drop the temp directory
rm -rf /var/www/tmp_$PROJECT_ID

echo "Done."
