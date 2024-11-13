#!/bin/bash
NAME=$1
DATA_FOLDER="/corpora/data"
REGISTRY_FOLDER="/corpora/registry"
VRT_FILES="/vrt_files"

# Note that the word and lemma fields ARE necessary, otherwise CWB cannot cope.
# Documentation for this field is available at 
VRT_FORMAT_STRUCTURE="-P word -P lemma -P analysis -P deps -P gloss -S sentence:0+id -S paragraph -S text:2+id+lang+title+author -S corpus:0+id -U \"\""
if [ "$NAME" = "bloomfield" ]; then
    VRT_FORMAT_STRUCTURE="-P word -P lemma -P analysis -P deps -P gloss -S sentence:0+id -S paragraph -S text:2+id+title+author -S corpus:0+id+lang -U \"\""
fi
if [ "$NAME" = "maskwacis-sentences" ]; then
   VRT_FORMAT_STRUCTURE="-P word -P lemma -P analysis -P gloss -S sentence:0+id+translation+recording+transcription+semantic-class/+speaker+session+timestamp  -U \"\""
fi

if [ "$NAME" = "blackfoot" ]; then
   VRT_FORMAT_STRUCTURE="-P word -P morphemes -P analysis -S sentence:0+id+translation -S text:0+_id+title -S corpora:2+title -U \"\""
fi

echo "Use ./import_vrt.sh filename_without_extension"
echo "for example, ./import_vrt.sh wolfart_ahenakew"
echo "file must be in the $VRT_FILES folder"

mkdir -v $DATA_FOLDER/$NAME
cwb-encode -s -p - -d $DATA_FOLDER/$NAME -R $REGISTRY_FOLDER/$NAME -c utf8 -B -f $VRT_FILES/$NAME.vrt $VRT_FORMAT_STRUCTURE
cwb-makeall -r $REGISTRY_FOLDER -D $NAME
cwb-huffcode -r $REGISTRY_FOLDER -A $NAME
rm -fv $DATA_FOLDER/$NAME/*.corpus
cwb-compress-rdx -r $REGISTRY_FOLDER -A $NAME
rm -fv $DATA_FOLDER/$NAME/*.rev
rm -fv $DATA_FOLDER/$NAME/*.rdx
if [ -f $REGISTRY_FOLDER/$NAME ];
then
   echo "Success! File $REGISTRY_FOLDER/$NAME is created!"
else
   echo "Failed to create $REGISTRY_FOLDER/$NAME"
   exit 1
fi