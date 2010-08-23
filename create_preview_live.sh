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



#Build the scaffolding for the repo

mkdir /tempProjects/$PROJECT_ID
mkdir /tempProjects/$PROJECT_ID/branches
mkdir /tempProjects/$PROJECT_ID/tags
mkdir /tempProjects/$PROJECT_ID/trunk



#Copy the files from the latest built Core

cp -r /var/www/Core2.4.1/assets /tempProjects/$PROJECT_ID/trunk/assets 
cp -r /var/www/Core2.4.1/mysite /tempProjects/$PROJECT_ID/trunk/mysite 
cp -r /var/www/Core2.4.1/themes /tempProjects/$PROJECT_ID/trunk/themes 
cp -r /var/www/Core2.4.1/.htaccess /tempProjects/$PROJECT_ID/trunk/.htaccess



