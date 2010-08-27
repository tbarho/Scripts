#/bin/bash

MODULES_ARRAY=("$@")

function usage {
        echo "$0 ( moduleX moduleY etc... )";
        exit 1;
}

if [ $# < 1 ]; then
        usage
fi

#echo the contents of the array with a do
echo "${MODULES_ARRAY[0]} ${MODULES_ARRAY[1]}"
