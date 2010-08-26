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

if [ -e "/var/www/sites/$PROJECT_ID" ]; then
	echo "There is already a directory named $PROJECT_ID in /var/www/sites.  Exiting..."
	exit;
else
	echo "$PROJECT_ID does not exist in /var/www/sites.  Proceeding..."
fi