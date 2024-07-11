# Configuration files for korp

There are several extra configuration files required to make korp work locally.

## Configuration requirements

Besides cloning this repo at some location, you need to also ensure
that your `korp-backend/config.py` has access to the location of this
repo through the following configuration line:

```
CORPUS_CONFIG_DIR = "/path/to/repo/korp-config/"
```

Also, in the frontend, create a `korp-frontend/run_config.json` file
with the following contents:

```
{
    "configDir": "/path/to/repo/korp-config"
}
```

## Adding corpora

**Corpus files are added via CWB tools**, and only then added to Korp
via the `corpora/` folder.  Note also that the documentation in the
repos is incomplete, as there are keys that are mentioned in the
documentation as /optional/ which are actually mandatory.

Although there are some [instructions in the original
documentation](https://cwb.sourceforge.io/files/CWB_Encoding_Tutorial.pdf),
those also need to be updated.

To add a `test_corpus.vrt` file as a corpus to Korp, one must **first** run the following commands on CWB:

```
# Generate the CWB corpus files
cwb-encode -s -p - -d /corpora/data/test_corpus -R /corpora/registry/test_corpus -c utf8 -f test_corpus.vrt -P word -P lemma -P msd -P dep -P gloss -S sentence:0+id -S paragraph -S text:0+id+lang+title+author -S corpus:0+id

# Generate the required indices
cwb-makeall -V test_corpus
```
**NOTE: Make sure you use absolute paths and not relative paths in `cwb-encode`, otherwise they will not be found by the backend later!**

And add the corresponding `korp-config/corpora/test_corpus.yaml` file,
which is already included in this repo.  Create new ones based on this
one for future use.

You must make sure that the output of the backend at
http://localhost:1234 shows the corpus of interest in the `corpora`
list, as follows:

![Screenshot 2024-07-10 at 4 47 38 PM](https://github.com/UAlbertaALTLab/korp-config/assets/248151/903f039a-92b4-4d0a-a294-591997658512)
