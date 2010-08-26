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

#Run all the checks

#Check if the DB password is good.  If not, exit.
mysql -u root -p$MYSQL_PWD -e"show databases;" &> /dev/null
RESULT=$?
if [ $RESULT -eq 1 ]; then
	echo "Password was wrong. Exiting."
	exit;
fi


#Check if the database exists.  If it does, exit.
DBS=`mysql -uroot -p$MYSQL_PWD -Bse 'show databases'|egrep -v 'information_schema|mysql'`
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

