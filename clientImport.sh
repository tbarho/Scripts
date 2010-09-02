#!/bin/bash

PROJECT_ID=$1
INPUT_FILE=$2
STRIP=$3

echo "'PROJECT_ID=$PROJECT_ID'"
echo "'INPUT_FILE=$INPUT_FILE'"
echo "'STRIP=$STRIP'"

function usage {
    echo "$0  [project id] [path/to/archive/file.tar.gz] [strip-components] ";
    exit 1;
}

if [ $# != 3 ]; then
    usage
fi

#Run all the checks

#Check if the database exists.  If it does, exit.
DBS=`mysql -uroot -p"Redrooster8" -Bse 'show databases'|egrep -v 'information_schema|mysql'`
for db in $DBS;
do
        if [ "$db" == $PROJECT_ID ]; then
                echo "Database exists";
                exit;
        fi
done



#Check if the project exists in SVN.  If it does, exit.
svn ls file:///var/svn/$PROJECT_ID &> /dev/null
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

#Check if the input file exists
if [ -e "$INPUT_FILE" ]; then
	echo "$INPUT_FILE found.  Proceeding...."
else
	echo "$INPUT_FILE does not exist.  Exiting....";
	exit;
fi


#If all the checks have passed, proceed with the site creation
echo "All checks passed.  Proceeding...."


#Create a temp directory scaffolding for SVN import
echo "Creating the scaffolding for the SVN project...."
mkdir "/var/www/tmp_$PROJECT_ID"
mkdir "/var/www/tmp_$PROJECT_ID/trunk"
mkdir "/var/www/tmp_$PROJECT_ID/branches"
mkdir "/var/www/tmp_$PROJECT_ID/tags"
mkdir "/var/www/tmp_$PROJECT_ID/backup"


# Export the tar file to the trunk
echo "Attempting to untar the input file...."
tar -xzf $INPUT_FILE --strip-components $STRIP -C /var/www/tmp_$PROJECT_ID/trunk

# Run a simple check to see if the /assets folder exists in trunk
if [ -e "/var/www/tmp_$PROJECT_ID/trunk/assets" ]; then
	echo "Found the assets file.  Looks like the untar worked correctly. Proceeding...."
else
	echo "Could not find /assets in the trunk folder. There was a problem.  Exiting...."
	exit;
fi

# Move any sql files to the backup directory
echo "Moving all .sql files to the /backup directory...."
mv /var/www/tmp_$PROJECT_ID/trunk/*.sql /var/www/tmp_$PROJECT_ID/backup

# Import project to SVN
echo "Importing project to SVN...."
svn import -q /var/www/tmp_$PROJECT_ID file:///var/svn/client_sites/$PROJECT_ID -m "IMPORT - Initial import of $PROJECT_ID"

# Delete the tmp directory
echo "Deleting the temporary directory...."
rm -rf /var/www/tmp_$PROJECT_ID


# Create the DB
echo "Creating the database $PROJECT_ID...."
mysql -e"CREATE DATABASE $PROJECT_ID;" -uroot -p"Redrooster8"


#Export the SQL file from /backup; Import into new DB
echo "Exporting the sql file from SVN and importing to the new DB...."
mkdir /var/www/tmp_sql
for i in $(svn ls file:///var/svn/client_sites/$PROJECT_ID/backup)
do
	if [ "$(file $i|grep sql)" ]; then
		svn export -q file:///var/svn/client_sites/$PROJECT_ID/backup/$i /var/www/tmp_sql/$i
	fi
done
mysql -u root -p"Redrooster8" "$PROJECT_ID" < "/var/www/tmp_sql/$i"
rm -rf /var/www/tmp_sql


# Export the project from SVN trunk to web root for client sites
echo "Exporting the project from SVN to the web root...."
svn export -q file:///var/svn/client_sites/$PROJECT_ID/trunk /var/www/sites/$PROJECT_ID


#TO DO:
# 1. Something about .htaccess files
# 2. Something about _config.php files pointing to the wrong db... grep?  yikes.



echo "Done.  Ready for /dev/build."




































