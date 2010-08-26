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

#XXX WHAT WE WANT TO HAPPEN XXX
# If password fail DB good returns FAIL -- EXIT
# If password good DB good returns FAIL -- EXIT
# If password fail DB fail returns FAIL -- EXIT
# If password good DB fail returns GOOD -- PROCEED TO COPY

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
