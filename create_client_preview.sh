#/bin/bash

PREVIEW_NAME=$1

echo "'PREVIEW_NAME=$PREVIEW_NAME'"

echo "Moving the the users /Sites directory..."
cd ~
cd Sites/
echo "Done."

echo "Creating the '$PREVIEW_NAME' directory..."
mkdir ~/Sites/$PREVIEW_NAME
echo "Done."

echo "Copying required files from /BaseInstall2.4.1"
cp -r ~/BaseInstall2.4.1/assets ~/Sites/$PREVIEW_NAME/assets 
cp -r ~/BaseInstall2.4.1/mysite ~/Sites/$PREVIEW_NAME/mysite 
cp -r ~/BaseInstall2.4.1/themes ~/Sites/$PREVIEW_NAME/themes 
cp -r ~/BaseInstall2.4.1/.htaccess ~/Sites/$PREVIEW_NAME/.htaccess
echo "Done."

echo "Symbolically linking the other necessary components from the core"
ln -s ~/BaseInstall2.4.1/sapphire/ ~/Sites/$PREVIEW_NAME/sapphire 
ln -s ~/BaseInstall2.4.1/cms/ ~/Sites/$PREVIEW_NAME/cms 
ln -s ~/BaseInstall2.4.1/googlesitemaps/ ~/Sites/$PREVIEW_NAME/googlesitemaps 
ln -s ~/BaseInstall2.4.1/index.php ~/Sites/$PREVIEW_NAME/index.php
echo "Done."

echo "Changing the db in the _config.php file"
echo "Done."

echo "Adding some module files."
echo "Done."

echo "Creating the DB named '$PREVIEW_NAME'"
echo "Done."

echo "Running a wget on the URL http://localhost/$PREVIEW_NAME to  install the DB"
echo "Done."

echo "Deleting everything when I'm done"

echo "Complete."

