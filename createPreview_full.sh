#/bin/bash


PROJECT_ID=$1
MYSQL_PWD=$2

echo "'PROJECT_ID=$PROJECT_ID'"

function usage {
    echo "$0  [project id] [mysql pwd]";
    exit 1;
}

if [ $# != 2 ]; then
    usage
fi