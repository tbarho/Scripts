#!/bin/bash

projectId=$1
dbName=$2
scripts=$3

#SOME HOW PARSE $3 AND STORE INDIVIDUAL VALUE IN THE STRING SEPEREATE BY SPACE INTO AN ARRAY
declare -a allMod

echo $projectId
echo $dbName

#POPULATE ARG 3 SELECTED MODULES STRING INTO A ARRAY
index=0
IFS=$' '
for i in $3
do
	selectedMod[index]=$i
	index+=`expr $index+1`
done
unset IFS

echo "seletedMod is: " ${selectedMod[*]}

#POPULATE ALL MODULES FROM SVN INTO ARRAY 
index=0
IFS=$'\n/'
for fileName in $(svn ls file:///var/svn/modules)
do
	#IMPORT ALL MODULES FROM SVN INTO ARRAY
	allMod[index]=$fileName
	index+=`expr $index+1`
done


echo "allMod is: " ${allMod[*]}

#COMPARE 2 ARRAYS FOR MATCHES
for i in ${allMod[*]}
do
	for j in ${selectedMod[*]}
	do
		if [ "$i" == "$j" ] ; then
			#WE WANT TO SVN EXPORT THIS FILE TO SOMEWHERE
			echo "svn export file:///var/svn/modules/"$j"/trunk /tmp/"$j				
			rm -rf /tmp/$j
			svn export file:///var/svn/modules/$j/trunk /tmp/$j				
		fi
	done
done
