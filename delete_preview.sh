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



#Delete the temp site
rm -rf /tempProjects/$PROJECT_ID

#Remove the project from SVN
svn delete file:///var/svn/$PROJECT_ID -m "Deleting $PROJECT_ID"

