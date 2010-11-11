#!/bin/sh
#================================================================================
# virtualhost.sh                                                            v1.04
#
# A fancy little script to setup a new virtualhost in Mac OS X.
#
# If you want to delete a virtualhost that you've created, you need to:
#
# sudo ./virtualhost.sh --delete <site>
#
# where <site> is the site name you used when you first created the host.
#
# CHANGES SINCE v1.03
# - An oversight in the change in v1.03 caused the ownership to be incorrect for
#   a tree of folders that was created. If your site folder is a few levels deep
#   we now fix the ownership properly of each nested folder.  (Thanks again to
#   Michael Allan for pointing this out.)
#
# - Improved the confirmation page for when you create a new virtual host. Not
#   only is it more informative, but it is also much more attractive.
#
# CHANGES SINCE v1.02
# - When creating the website folder, we now create all the intermediate folders
#   in the case where a user sets their folder to something like 
#   clients/project_a/mysite. (Thanks to Michael Allan for pointing this out.)
#
# CHANGES SINCE v1.01
# - Allow for the configuration of the Apache configuration path and the path to
#   apachectl.
#
# CHANGES SINCE v1.0
# - Use absolute path to apachectl, as it looks like systems that were upgraded
#   from Jaguar to Panther don't seem to have it in the PATH.
#
#
# by Patrick Gibson <patrick@patrickg.com>
#================================================================================
#
# If you are using this script on a production machine with a static IP address,
# and you wish to setup a "live" virtualhost, you can change the following IP
# address to the IP address of your machine.
#
IP_ADDRESS="127.0.0.1"

# By default, this script places files in /Users/[you]/Sites. If you would like
# to change this, like to how Apple does things by default, uncomment the
# following line:
#
#DOC_ROOT_PREFIX="/Library/WebServer/Documents"

# Configure the apache-related paths
#
APACHE_CONFIG="/etc/httpd"
APACHECTL="/usr/sbin/apachectl"

# By default, use the site folders that get created will be 0wn3d by this group
OWNER_GROUP="staff"

if uname -r | grep -q -e '^9' ; then
	echo "This version of virtualhost.sh is not Leopard-compatible."
	echo
	echo "Downloading the correct version..."
	cd /tmp
	ftp -V http://patrickgibson.com/etc/virtualhost-leopard.tgz
	if [ -e /tmp/virtualhost-leopard.tgz ]; then
		tar xzf /tmp/virtualhost-leopard.tgz
		mv /tmp/virtualhost.sh ~/Desktop
		echo "virtualhost.sh has been downloaded and placed on your Desktop. Please delete this version now."
	else
		echo "Could not download updated version. You can download it manually from here:"
		echo
		echo "http://patrickg.com/etc/virtualhost-leopard.tgz"
	fi
	exit
elif [ `whoami` != 'root' ]; then

	echo "You must be running with root privileges to run this script."
	exit

fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ -z $USER -o $USER = "root" ]; then
	if [ ! -z $SUDO_USER ]; then
		USER=$SUDO_USER
	else
		USER=""

		echo "ALERT! Your root shell did not provide your username."

		while : ; do
			if [ -z $USER ]; then
				while : ; do
					echo -n "Please enter *your* username: "
					read USER
					if [ -d /Users/$USER ]; then
						break
					else
						echo "$USER is not a valid username."
					fi
				done
			else
				break
			fi
		done
	fi
fi

if [ -z $DOC_ROOT_PREFIX ]; then
	DOC_ROOT_PREFIX="/Users/$USER/Sites"
fi

usage()
{
	cat << __EOT
Usage: sudo virtualhost.sh <name>
       sudo virtualhost.sh --delete <name>
   where <name> is the one-word name you'd like to use. (e.g. mysite)
   
   Note that if "virtualhost.sh" is not in your PATH, you will have to write
   out the full path to it: eg. /Users/$USER/Desktop/virtualhost.sh <name>

__EOT
	exit 1
}

if [ -z $1 ]; then
	usage
else
	if [ $1 = "--delete" ]; then
		if [ -z $2 ]; then
			usage
		else
			VIRTUALHOST=$2
			DELETE=0
		fi		
	else
		VIRTUALHOST=$1
	fi
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Delete the virtualhost if that's the requested action
#
if [ ! -z $DELETE ]; then
	echo -n "- Deleting virtualhost, $VIRTUALHOST... Continue? [Y/n]: "

	read continue
	
	case $continue in
	n*|N*) exit
	esac

	if niutil -list . /machines/$VIRTUALHOST 2>/dev/null ; then
		echo -n "  - Removing $VIRTUALHOST from NetInfoManager... "
				
		niutil -destroy . /machines/$VIRTUALHOST
		echo "done"
		
		if [ -e $APACHE_CONFIG/virtualhosts/$VIRTUALHOST ]; then
			DOCUMENT_ROOT=`grep DocumentRoot $APACHE_CONFIG/virtualhosts/$VIRTUALHOST | awk '{print $2}'`

			if [ -d $DOCUMENT_ROOT ]; then
				echo -n "  + Found DocumentRoot $DOCUMENT_ROOT. Delete this folder? [y/N]: "

				read resp
			
				case $resp in
				y*|Y*)
					echo -n "  - Deleting folder... "
					if rm -rf $DOCUMENT_ROOT ; then
						echo "done"
					else
						echo "Could not delete $DOCUMENT_ROOT"
					fi
				;;
				esac
				
				echo -n "  - Deleting virtualhost file... ($APACHE_CONFIG/virtualhosts/$VIRTUALHOST) "
				rm $APACHE_CONFIG/virtualhosts/$VIRTUALHOST
				echo "done"

				echo -n "+ Restarting Apache... "
				/usr/sbin/apachectl graceful 1>/dev/null 2>/dev/null
				echo "done"
			fi
		fi
	else
		echo "- Virtualhost $VIRTUALHOST does not currently exist. Aborting..."
	fi

	exit
fi


FIRSTNAME=`niutil -readprop . /users/$USER realname | awk '{print $1}'`
cat << __EOT
Hi $FIRSTNAME! Welcome to virtualhost.sh. This script will guide you through setting
up a name-based virtualhost. 

__EOT

echo -n "Do you wish to continue? [Y/n]: "

read continue

case $continue in
n*|N*) exit
esac


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Make sure $APACHE_CONFIG/httpd.conf is ready for virtual hosting...
#
# If it's not, we will:
#
# a) Backup the original to $APACHE_CONFIG/httpd.conf.original
# b) Add a NameVirtualHost 127.0.0.1 line
# c) Create $APACHE_CONFIG/virtualhosts/ (virtualhost definition files reside here)
# d) Add a line to include all files in $APACHE_CONFIG/virtualhosts/
# e) Create a _localhost file for the default "localhost" virtualhost
#

if ! grep -q -e "^DocumentRoot \"$DOC_ROOT_PREFIX\"" $APACHE_CONFIG/httpd.conf ; then
	echo "httpd.conf's DocumentRoot does not point where it should."
	echo -n "Do you with to set it to $DOC_ROOT_PREFIX? [Y/n]: "	
	read DOCUMENT_ROOT
	case $DOCUMENT_ROOT in
	n*|N*)
		echo "Okay, just re-run this script if you change your mind."
	;;
	*)
		cat << __EOT | ed $APACHE_CONFIG/httpd.conf 1>/dev/null 2>/dev/null
/^DocumentRoot
i
#
.
j
+
i
DocumentRoot "$DOC_ROOT_PREFIX"
.
w
q
__EOT
	;;
	esac
fi

if ! grep -q -E "^NameVirtualHost $IP_ADDRESS" $APACHE_CONFIG/httpd.conf ; then

	echo "httpd.conf not ready for virtual hosting. Fixing..."
	cp $APACHE_CONFIG/httpd.conf $APACHE_CONFIG/httpd.conf.original
	echo "NameVirtualHost $IP_ADDRESS" >> $APACHE_CONFIG/httpd.conf
	
	if [ ! -d $APACHE_CONFIG/virtualhosts ]; then
		mkdir $APACHE_CONFIG/virtualhosts
		cat << __EOT > $APACHE_CONFIG/virtualhosts/_localhost
<VirtualHost $IP_ADDRESS>
  DocumentRoot $DOC_ROOT_PREFIX
  ServerName localhost

  ScriptAlias /cgi-bin $DOC_ROOT_PREFIX/cgi-bin

  <Directory $DOC_ROOT_PREFIX>
    Options All
    AllowOverride All
  </Directory>
</VirtualHost>
__EOT
	fi

	echo "Include /private$APACHE_CONFIG/virtualhosts"  >> $APACHE_CONFIG/httpd.conf


fi


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# If the machine is not already defined in NetInfo Manager, define it...
#

if niutil -list . /machines/$VIRTUALHOST 2>/dev/null ; then

	echo "- $VIRTUALHOST already exists."
	echo -n "Do you want to replace this configuration? [Y/n] "
	read resp

	case $resp in
	n*|N*)	exit
	;;
	esac

else
	if [ $IP_ADDRESS != "127.0.0.1" ]; then
		cat << _EOT
We would now normally add an entry in your NetInfoManager so that
you can access this virtualhost using a name rather than a number.
However, since you have set the virtualhost to something other than
127.0.0.1, this may not be necessary. (ie. there may already be a DNS
record pointing to this IP)

_EOT
		echo -n "Do you want to add this anyway? [y/N] "
		read add_net_info

		case $add_net_info in
		y*|Y*)	exit
		;;
		esac
	fi
	echo 
	echo "Creating a virtualhost for $VIRTUALHOST..."
	echo -n "+ Adding $VIRTUALHOST to NetInfoManager... "
	niutil -create . /machines/$VIRTUALHOST
	niutil -createprop . /machines/$VIRTUALHOST ip_address 127.0.0.1           
	niutil -createprop . /machines/$VIRTUALHOST name $VIRTUALHOST
	niutil -createprop . /machines/$VIRTUALHOST serves './local'
	echo "done"
fi


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Ask the user where they would like to put the files for this virtual host
#
echo -n "+ Checking for $DOC_ROOT_PREFIX/$VIRTUALHOST... "

if [ ! -d $DOC_ROOT_PREFIX/$VIRTUALHOST ]; then
	echo "not found"
else
	echo "found"
fi
	
echo -n "  - Use $DOC_ROOT_PREFIX/$VIRTUALHOST as the virtualhost folder? [Y/n] "

read resp

case $resp in

	n*|N*) 
		while : ; do
			if [ -z $FOLDER ]; then
				echo -n "  - Enter new folder name (located in Sites): "
				read FOLDER
			else
				break
			fi
		done
	;;

	*) FOLDER=$VIRTUALHOST
	;;
esac


# Create the folder if we need to...
if [ ! -d $DOC_ROOT_PREFIX/$FOLDER ]; then
	echo -n "  + Creating folder $DOC_ROOT_PREFIX/$FOLDER... "
	# su $USER -c "mkdir -p $DOC_ROOT_PREFIX/$FOLDER"
	mkdir -p $DOC_ROOT_PREFIX/$FOLDER
	
	# If $FOLDER is deeper than one level, we need to fix permissions properly
	case $FOLDER in
		*/*)
			subfolder=0
		;;
	
		*)
			subfolder=1
		;;
	esac

	if [ $subfolder != 1 ]; then
		# Loop through all the subfolders, fixing permissions as we go
		#
		# Note to fellow shell-scripters: I realize that I could avoid doing
		# this by just creating the folders with `su $USER -c mkdir ...`, but
		# I didn't think of it until about five minutes after I wrote this. I
		# decided to keep with this method so that I have a reference for myself
		# of a loop that moves down a tree of folders, as it may come in handy
		# in the future for me.
		dir=$FOLDER
		while [ $dir != "." ]; do
			chown $USER:$OWNER_GROUP $DOC_ROOT_PREFIX/$dir
			dir=`dirname $dir`
		done
	else
		chown $USER:$OWNER_GROUP $DOC_ROOT_PREFIX/$FOLDER
	fi
	
	echo "done"
fi


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create a default index.html if there isn't already one there
#
if [ ! -e $DOC_ROOT_PREFIX/$FOLDER/index.html -a ! -e $DOC_ROOT_PREFIX/$FOLDER/index.php ]; then

	cat << __EOF >$DOC_ROOT_PREFIX/$FOLDER/index.html
<html>
<head>
<title>Welcome to $VIRTUALHOST</title>
</head>
<style type="text/css">
 body, div, td { font-family: "Lucida Grande"; font-size: 12px; color: #666666; }
 b { color: #333333; }
 .indent { margin-left: 10px; }
</style>
<body link="#993300" vlink="#771100" alink="#ff6600">

<table border="0" width="100%" height="95%"><tr><td align="center" valign="middle">
<div style="width: 500px; background-color: #eeeeee; border: 1px dotted #cccccc; padding: 20px; padding-top: 15px;">
 <div align="center" style="font-size: 14px; font-weight: bold;">
  Congratulations!
 </div>

 <div align="left">
  <p>If you are reading this in your web browser, then the only logical conclusion is that the <b><a href="http://$VIRTUALHOST/">http://$VIRTUALHOST/</a></b> virtualhost was setup correctly. :)</p>
  
  <p>You can find the configuration file for this virtual host in:<br>
  <table class="indent" border="0" cellspacing="3">
   <tr>
    <td><img src="/icons/script.gif" width="20" height="22" border="0"></td>
    <td><b>$APACHE_CONFIG/virtualhosts/$VIRTUALHOST</b></td>
   </tr>
  </table>
  </p>
  
  <p>You will need to place all of your website files in:<br>
  <table class="indent" border="0" cellspacing="3">
   <tr>
    <td><img src="/icons/dir.gif" width="20" height="22" border="0"></td>
    <td><b><a href="file://$DOC_ROOT_PREFIX/$FOLDER">$DOC_ROOT_PREFIX/$FOLDER</b></a></td>
   </tr>
  </table>
  </p>
  
  <p>For the latest version of this script, tips, comments, <span style="font-size: 10px; color: #999999;">donations,</span> etc. visit:<br>
  <table class="indent" border="0" cellspacing="3">
   <tr>
    <td><img src="/icons/forward.gif" width="20" height="22" border="0"></td>
    <td><b><a href="http://patrickg.com/virtualhost">http://patrickg.com/virtualhost</a></b></td>
   </tr>
  </table>
  </p>
 </div>

</div>
</td></tr></table>

</body>
</html>
__EOF
	chown $USER:$OWNER_GROUP $DOC_ROOT_PREFIX/$FOLDER/index.html

fi	


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create a default virtualhost file
#
echo -n "+ Creating virtualhost file... "
cat << __EOF >$APACHE_CONFIG/virtualhosts/$VIRTUALHOST
<VirtualHost 127.0.0.1>
  DocumentRoot $DOC_ROOT_PREFIX/$FOLDER
  ServerName $VIRTUALHOST

  ScriptAlias /cgi-bin $DOC_ROOT_PREFIX/$FOLDER/cgi-bin

  <Directory $DOC_ROOT_PREFIX/$FOLDER>
    Options All
    AllowOverride All
  </Directory>
</VirtualHost>
__EOF

echo "done"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Restart apache for the changes to take effect
#
echo -n "+ Restarting Apache... "
$APACHECTL graceful 1>/dev/null 2>/dev/null
echo "done"

cat << __EOF

http://$VIRTUALHOST/ is setup and ready for use.

__EOF


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Launch the new URL in the browser
#
echo -n "Launching virtualhost... "
open http://$VIRTUALHOST/
echo "done"

