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

echo "Checking if SS"$PROJECT_ID" exists..."
if [ -e "/Users/tybarho/Sites/SS$PROJECT_ID" ]; then
	echo "There is already a project named SS$PROJECT_ID in ~/Sites.  Exiting...."
	exit 1;
fi

echo "Checking if $PROJECT_ID database exists..."
DBS=`mysql -u root -p"root" -Bse 'show databases'|egrep -v 'information_shema|mysql'`
for db in $DBS;
do
	if [ "$db" == $PROJECT_ID ]; then
		echo "Database $PROJECT_ID exists. Exiting...."
		exit 1;
	fi
done

echo "All checks have passsed.  Proceeding with site creation...."

echo "Creating the directory $PROJECT_ID directory in ~/Sites"
mkdir "/Users/tybarho/Sites/SS$PROJECT_ID"

echo "Checking out the source from remote SVN..."
svn co svn+ssh://ty@sitesprocket.com/var/svn/client_sites/$PROJECT_ID/trunk /Users/tybarho/Sites/SS$PROJECT_ID

echo "Creating the sym links"
ln -s "/Users/tybarho/Core2.4.1/trunk/sapphire" "/Users/tybarho/Sites/SS"$PROJECT_ID"/sapphire"
ln -s "/Users/tybarho/Core2.4.1/trunk/cms" "/Users/tybarho/Sites/SS"$PROJECT_ID"/cms"
ln -s "/Users/tybarho/Core2.4.1/trunk/googlesitemaps" "/Users/tybarho/Sites/SS"$PROJECT_ID"/googlesitemaps"
ln -s "/Users/tybarho/Core2.4.1/trunk/index.php" "/Users/tybarho/Sites/SS"$PROJECT_ID"/index.php"


echo "Creating the database for the project"
mysql -e"CREATE DATABASE $PROJECT_ID;" -u root -p"root"

echo "Project created.  Be sure to browse to http://localhost/SS"$PROJECT_ID"/dev/build?flush=1 to rebuild the database."

exit 0;

echo "Untar archive"
mkdir -p "$OUTPUT_DIR"
tar -zxvf "$INPUT_FILE" -C"$OUTPUT_DIR"

echo "Dropping old database"
mysql -e"DROP DATABASE IF EXISTS $DATABASE;" -u root -p"root"

echo "Create database"
mysql -e"CREATE DATABASE $DATABASE;" -u root -p"root"

echo "Install database"
mysql -u root -p"root" "$DATABASE" < "$OUTPUT_DIR"/db.sql

exit 1;
