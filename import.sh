#/bin/bash

DATABASE=$1
OUTPUT_DIR=$2
INPUT_FILE=$3

echo "'DATABASE=$DATABASE'"
echo "'OUTPUT_DIR=$OUTPUT_DIR'"
echo "'INPUT_FILE=$INPUT_FILE'"

function usage {
    echo "$0  [database] [output_dir] [input_file]";
    exit 1;
}

if [ $# != 3 ]; then
    usage
fi

echo "Untar archive"
mkdir -p "$OUTPUT_DIR"
tar -zxvf "$INPUT_FILE" -C"$OUTPUT_DIR"

echo "Dropping old database"
mysql -e"DROP DATABASE IF EXISTS $DATABASE;" -u root -p"root"

echo "Create datase"
mysql -e"CREATE DATABASE $DATABASE;" -u root -p"root"

echo "Install database"
mysql -u root -p"root" "$DATABASE" < "$OUTPUT_DIR"/db.sql

exit 1;
