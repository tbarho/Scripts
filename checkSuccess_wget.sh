#/bin/bash

/usr/bin/wget -O /var/www/sites/ProjectA/build-verification.html http://sites.sitesprocket.com/ProjectA/dev/build?flush=1 2>&1
echo "Response was $?"