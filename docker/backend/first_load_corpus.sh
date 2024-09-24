#/bin/bash
# This script updates a corpus.
NAME=$1
DATA_FOLDER="/corpora/data"
REGISTRY_FOLDER="/corpora/registry"
VRT_FILES="/vrt_files"

echo "Attempting to upload the \"$NAME\" corpus."
if [ -f $VRT_FILES/$NAME.vrt ]; then
    echo "Found the $NAME.vrt file..."
    if [ -f $REGISTRY_FOLDER/$NAME ]; then
        echo "The corpus name is already registered in CWB!  Try to update_corpus.sh instead."
        exit 1
    fi
    if [ -d $DATA_FOLDER/$NAME ]; then
        echo "The corpus name has a data folder for CWB, even though the corpus is not registered!"
        echo "Remove the $DATA_FOLDER/$NAME to first import the corpus."
    fi
    /app/import_vrt.sh $NAME
    /app/recount_sentences.sh $NAME
else
    echo "I cannot find the $NAME.vrt file."
    echo "Please place it in the appropriate folder (see docker-compose.yml)"
fi