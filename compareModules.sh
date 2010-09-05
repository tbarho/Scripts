#!/bin/bash

# Check for old versions of modules dataobject_manager, userforms, swfupload

PROJECT_ID=$1

declare -a ALL_MODULES
declare -a CLIENT_MODULES


ALL_MODULES=( ${ALL_MODULES[@]} $(
		svn ls file:///var/svn/modules | { 
			while read i; do
				echo ${i%/}	
			done
		}	
	))

echo "ALL_MODULES: ${ALL_MODULES[*]}"

CLIENT_MODULES=( ${CLIENT_MODULES[@]} $(
		svn ls file:///var/svn/client_sites/$PROJECT_ID/trunk |grep "/" | {
			while read i; do
				echo ${i%/}
			done
		}
	))

echo "CLIENT_MODULES: ${CLIENT_MODULES[*]}"

for i in ${ALL_MODULES[*]}
do
	for j in ${CLIENT_MODULES[*]}
		do
			if [ "$i" == "$j" ]; then
				echo "found: $j"
			fi
		done
done
