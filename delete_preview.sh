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



#Delete the web site
rm -rf /var/www/html/$PROJECT_ID

