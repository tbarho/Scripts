#!/bin/bash

for i in $(svn ls file:///var/svn/client_sites/CellingTreatmentCenters/backup)
do
	if [  "$(file $i|grep sql)" ]; then
		echo "[ $i ]"
	fi
done
