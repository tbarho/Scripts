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





