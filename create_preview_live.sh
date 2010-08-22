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
	
	#Export the newly created project to the live preview site
	svn export file:///var/svn/$PROJECT_ID /var/www/html/$PROJECT_ID
