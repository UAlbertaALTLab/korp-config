#!/bin/bash

set -eu
set -xv

#CWB_PATH=$(ls -d /usr/local/cwb-*/bin) # something like /usr/local/cwb-3.4.32/bin
#PATH="${CWB_PATH}:${PATH}"

corpus_data="/Users/banadoss/korp/corpora/data"
registry="/Users/banadoss/korp/corpora/registry"
input_data="/Users/banadoss/korp"
date=$(date +%Y-%m-%d)
descriptive_name="Plains Cree: Wolfart-Ahenakew Texts"
lang_code="crk"
l_corpus_name="wolfart_ahenakew" # Short name (base name) of vrt corpus file
# u_corpus_name=${l_corpus_name^^}
mkdir -vp $corpus_data/$l_corpus_name
sent_nr=$(cat $input_data/$l_corpus_name.vrt|grep '<sentence'|wc -l)
cat > $corpus_data/$l_corpus_name/.info << EOF
Sentences: $sent_nr
Updated: $date
EOF
echo " ....... created $corpus_data/$l_corpus_name/.info"
cwb-encode -s -p - -d $corpus_data/$l_corpus_name -R $registry/$l_corpus_name -c utf8 -f $input_data/$l_corpus_name.vrt -P word -P lemma -P msd -P dep -P gloss -S sentence:0+id -S paragraph -S text:0+id+lang+title+author -S corpus:0+id
echo " ....... $l_corpus_name converted into the CWB binary format"
cwb-makeall -r $registry -D $l_corpus_name
echo " ....... created lexicon and index for p-attributes for $l_corpus_name"
cwb-huffcode -r $registry -A $l_corpus_name
echo " ....... compressed the token sequence of positional attributes for $l_corpus_name"
rm -fv $corpus_data/$l_corpus_name/*.corpus
cwb-compress-rdx -r $registry -A $l_corpus_name
echo " ....... compressed the index of positional attributes for $l_corpus_name"
rm -fv $corpus_data/$l_corpus_name/*.rev
rm -fv $corpus_data/$l_corpus_name/*.rdx
if [ -f $registry/$l_corpus_name ];
then
   echo "Success! File $registry/$l_corpus_name is created!"
   name_placeholder='NAME ""' # Sets placeholder - don't edit
   name_string='NAME "'$descriptive_name'"'
   lang_placeholder='language = "??"' # Sets placeholder - don't edit
   lang_string='language = "'$lang_code'"'
   sed -i "s/${name_placeholder}/${name_string}/; s/${lang_placeholder}/${lang_string}/;" $registry/$l_corpus_name
else
   echo "Failed to create $registry/$l_corpus_name"
   exit 1
fi
