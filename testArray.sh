#!/bin/bash

PROJECTID=$1
DBNAME=$2
SCRIPTS=$3

IFS=$' '

#SOME HOW PARSE $3 AND STORE INDIVIDUAL VALUE IN THE STRING SEPEREATE BY SPACE INTO AN ARRAY
ARRAY=$3

#use $@ to print out all arguments at once
#echo $@ ' -> echo $@'
#echo $# ' -> number of arguments'

#echo $VAR

#for ((i = 2; i < "${#ARRAY[@]}"; i++))
#do
#	echo ${ARRAY[i]}	
#done

echo $PROJECTID

echo $DBNAME

for i in $ARRAY
do
	echo "$i"	
done
