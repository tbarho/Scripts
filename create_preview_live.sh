#/bin/bash

$PROJECT_ID=$1

echo "'PROJECT_ID=$PROJECT_ID'"

function usage {
    echo "$0  [project id]";
    exit 1;
}

if [ $# != 1 ]; then
    usage
fi

#TODO: When a client clicks order, to create a preview site

#Create the repository

	#Make temp directory and checkout core
	mkdir /tmpprojects/$PROJECT_ID
	svn co file:///var/svn/Core2.4.1 /tmpprojects/$PROJECT_ID
	
	#Remove unnecessary files / folders
	rm -rf ChangeLog 
	rm -rf cms
	rm -rf COPYING
	rm -rf favicon.ico 
	rm -rf googlesitemaps/
	rm -rf index.php 
	rm -rf INSTALL 
	rm -rf install.php 
	rm -rf MakeFile
	rm -rf sapphire/
	rm -rf _ss_environment.php 
	rm -rf UPGRADING 
	rm -rf web.config 
	
	#SVN Import as new Repo
	svn import /tmpprojects/$PROJECT_ID file:///var/svn/$PROJECT_ID -m "Initial Import - Client Preview $PROJECT_ID"
	
	#Delete the temp folder
	rm -rf /tmpprojects/$PROJECT_ID
	
#Get the preview site working
	
	#Export the $PROJECT_ID to the web root as a new site
	svn export file:///var/svn/$PROJECT_ID /var/www/html/$PROJECT_ID
	
	#Create the database
	mysql -e"CREATE DATABASE $PROJECT_ID;" -u root -p"password"
	
	#Edit the config to point to the new database
	rm /var/www/html/$PROJECT_ID/mysite/_config.php
	sed "s/{PREVIEW_NAME}/$PROJECT_ID/g" /var/www/Core2.4.1/trunk/mysite/_config.php > /var/www/html/$PROJECT_ID/mysite/_config.php
	
	#Add the symbolic links to the working core
	ln -s /var/www/Core2.4.1/trunk/sapphire/ /var/www/html/$PROJECT_ID/sapphire 
	ln -s /var/www/Core2.4.1/trunk/cms/ /var/www/html/$PROJECT_ID/cms 
	ln -s /var/www/Core2.4.1/trunk/googlesitemaps/ /var/www/html/$PROJECT_ID/googlesitemaps 
	ln -s /var/www/Core2.4.1/trunk/index.php /var/www/html/$PROJECT_ID/index.php
	
	#Run a wget to build the database
	/usr/local/bin/wget -O /var/www/html/"$PROJECT_ID"/build-verification.html http://www.sitesprocket.com/"$PROJECT_ID"/dev/build?flush=1 2>&1


