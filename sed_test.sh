#/bin/bash

PREVIEW_NAME=$1

sed "s/{PREVIEW_NAME}/$PREVIEW_NAME/g" ~/BaseInstall2.4.1/mysite/_config.php > ~/Sites/$PREVIEW_NAME/mysite/_config.php