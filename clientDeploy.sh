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

# If all the checks have passed, proceed
echo "All checks passed. Proceeding...."


# Remove the existng client site
echo "Removing the existing client site...."
rm -rf /var/www/sites/$PROJECT_ID


# Export the updated project from SVN
echo "Exporting the updated project from SVN...."
svn export -q file:///var/svn/client_sites/$PROJECT_ID/trunk /var/www/sites/$PROJECT_ID

# Create the sym links to the core
echo "Creating the sym links to the core files...."
ln -s /var/www/Core2.4.1/sapphire/ /var/www/sites/$PROJECT_ID/sapphire
ln -s /var/www/Core2.4.1/cms/ /var/www/sites/$PROJECT_ID/cms
ln -s /var/www/Core2.4.1/googlesitemaps/ /var/www/sites/$PROJECT_ID/googlesitemaps
ln -s /var/www/Core2.4.1/index.php /var/www/sites/$PROJECT_ID/index.php

echo "Done.  Ready for /dev/build."
