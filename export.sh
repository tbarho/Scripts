#/bin/bash

DATABASE=$1
OUTPUT_FILE=$2
INPUT_DIR=$3

echo "'DATABASE=$DATABASE'"
echo "'OUTPUT_FILE=$OUTPUT_FILE'"
echo "'INPUT_DIR=$INPUT_DIR'"

function usage {
    echo "$0  [database] [output_file] [input directory]";
    exit 1;
}

if [ $# != 3 ]; then
    usage
fi

echo "Dump current database"
mysqldump -u root -p"root" "$DATABASE" > "$INPUT_DIR"/db.sql

echo "Creating new site in web root"

tar -czvf "$OUTPUT_FILE".tgz -C"$INPUT_DIR" .

exit 1;
