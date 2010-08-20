#/bin/bash

PREVIEW_NAME=$1

echo "'PREVIEW_NAME=$PREVIEW_NAME'"

function usage {
    echo "$0  [database] [output_file] [input directory]";
    exit 1;
}

if [ $# != 1 ]; then
    usage
fi

echo "Creating the DB named '$PREVIEW_NAME'"
mysql -e"CREATE DATABASE $PREVIEW_NAME;" -u root -p"root"
echo "Done."

echo "Creating the '$PREVIEW_NAME' directory..."
mkdir ~/Sites/$PREVIEW_NAME
echo "Done."

echo "Copying required files from /Core2.4.1"
cp -r ~/Core2.4.1/trunk/assets ~/Sites/$PREVIEW_NAME/assets 
cp -r ~/Core2.4.1/trunk/mysite ~/Sites/$PREVIEW_NAME/mysite 
cp -r ~/Core2.4.1/trunk/themes ~/Sites/$PREVIEW_NAME/themes 
cp -r ~/Core2.4.1/trunk/.htaccess ~/Sites/$PREVIEW_NAME/.htaccess
echo "Done."

echo "Symbolically linking the other necessary components from the core"
ln -s ~/Core2.4.1/trunk/sapphire/ ~/Sites/$PREVIEW_NAME/sapphire 
ln -s ~/Core2.4.1/trunk/cms/ ~/Sites/$PREVIEW_NAME/cms 
ln -s ~/Core2.4.1/trunk/googlesitemaps/ ~/Sites/$PREVIEW_NAME/googlesitemaps 
ln -s ~/Core2.4.1/trunk/index.php ~/Sites/$PREVIEW_NAME/index.php
echo "Done."

echo "Changing the db in the _config.php file"
rm ~/Sites/$PREVIEW_NAME/mysite/_config.php
sed "s/{PREVIEW_NAME}/$PREVIEW_NAME/g" ~/Core2.4.1/trunk/mysite/_config.php > ~/Sites/$PREVIEW_NAME/mysite/_config.php
echo "Done."

echo "Adding some module files via symlink."
echo "Done."

echo "Running a wget on the URL http://localhost/$PREVIEW_NAME to  install the DB"
/usr/local/bin/wget -O ~/Sites/"$PREVIEW_NAME"/build-verification.html http://localhost/"$PREVIEW_NAME"/dev/build?flush=1 2>&1
echo "Done."



