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

#check if the project exists in SVN.  If it does, exit.
svn ls file:///var/svn/$PROJECT_ID &> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ]; then
	echo "SVN repo for $PROJECT_ID already exists. Exiting..."
	exit;
else
	echo "SVN repo for $PROJECT_ID does notexists. Proceeding..."
fi


