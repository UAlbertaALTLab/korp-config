#/bin/bash
# This script updates a corpus.
NAME=$1
DATA_FOLDER="/corpora/data"
REGISTRY_FOLDER="/corpora/registry"

read -p "Do you really want to update the \"$NAME\" corpus? (y/n)"
if [ $REPLY == 'y' ]; then
    echo "Performing corpus update for $NAME..."
    rm -v $REGISTRY_FOLDER/$NAME
    rm -rv $DATA_FOLDER/$NAME
    /app/import_vrt.sh $NAME
    /app/recount_sentences.sh $NAME
else
    echo "Nothing done."
fi