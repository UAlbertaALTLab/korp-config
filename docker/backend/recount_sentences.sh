#!/bin/bash
NAME=$1
VRT_FILES="/vrt_files"
DATA_FOLDER="/corpora/data"

echo "This script counts the lines and generates the relevant info."

WC=$(grep "<sentence " "$VRT_FILES/$NAME.vrt"| wc -l)
echo "Sentences: $WC" > "$DATA_FOLDER/$NAME/.info"