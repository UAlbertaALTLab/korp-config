# Altlab Korp deployment repo

This repo contains all files required to deploy korp in our infrastructure.
There's three parts to this mayhem:
1. The configuration files expected by both korp-frontend and korp-backend, which is most of the content in this repository.
2. The files required to generate our docker images for both the frontend and the backend (in `docker/`). 
   - The `docker/docker-compose.yml` file includes instructions for the deployment of our images
   - The `docker/deploy` script contains all commands required to perform a "korp upgrade" in the repo:  These upgrades are **for local altlab changes only**:  The versions of korp-frontend, korp-backend, and cwb are fixed and updates to those are likely to require further changes in the code, so developers are expected to manually change versions when needed by modifying the docker files.
   - The image folders, `backend/` and `frontend/`.  Each contains:
     - A `Dockerfile` with the instructions to make the images
     - A set of files that have been customized and that need to replace other files in their respective korp codebases. *Eventually we could instead have forks of the source repos, but the effort in rebasing and identifying repo divergences seems equivalent.*
3. The `corpora` configuration files and the scripts that can properly import `vrt` files into korp.

## How do I update a corpus already in korp?
If you follow our instructions to upload a new corpus, later updates to the `.vrt` file require only the following (say, for example, for the `bloomfield` corpus):
1. Copy the `bloomfield.vrt` file to the appropriate location:  **Check the folder mappings in `docker/docker-compose.yml` for up-to-date info**, but it is likely to be just `altlab-itw:/data_local/application-data/korp-backend/vrt_files`.  Ensure that the `korp` user has read access to this file. If you have `sudo` powers in `altlab-itw`, you can move the file from your local computer to the appropriate location 
```
     local$ scp bloomfield.vrt altlab.dev:
     local$ ssh altlab.dev
 altlab-gw$ scp bloomfield.vrt altlab-itw:
 altlab-gw$ ssh altlab-itw:
altlab-itw$ sudo -u korp cp -v bloomfield.vrt /data_local/application-data/korp-backend/vrt_files/
```

2. Run the `update_corpus` script with the corpus name **without the `vrt` extension**.  If you just ran the previous step:
```
 you@altlab-itw$ sudo -i -u korp
korp@altlab-itw$ cd korp-config/docker/
korp@altlab-itw$ docker-compose exec korp-backend bash /app/update_corpus.sh bloomfield
``` 
Respond `y` and press enter when asked to confirm that you want to update this corpus.

## How do I add a new corpus to korp?
There are some steps involved in the generation of a new corpus.  

### Generate a .vrt file
You will likely want to read and understand the [CWB Corpus Encoding and Management Manual](https://cwb.sourceforge.io/files/CWB_Encoding_Tutorial.pdf).  But there are some details that are missing in this documentation:
- **The backend is very sensitive to the use of characters that it may consider as escape characters**. In particular, this means that you want to avoid the usage of spaces ` ` or slashes `/` in any p-attributes.  We ask that you follow these conventions in `vrt` files:
  - Replace all occurrences of a space in a field (e.g. glosses) with the `&#x20;` HTML entity string. The frontend still shows that entity as a space, and extended search inserts these characters automatically when there is a space in a search item.
  - Replace most occurrences of a slash in a field (e.g. glosses) with the `&sol;` HTML entity string. **Do not replace slashes in the word p-attribute** (usually the first one).  The frontend does not escape the HTML entity inside the text of the sentence.
  - Replace all other escape characters used by CWB: (`<` by `&lt;`, `>` by `&gt;`, and `|` by `&vert;`)

Once you have a `.vrt` file, you can continue the process.

### Generate the configuration files for the frontend to show your corpus
1. Create a `corpora/corpus_name.yaml` file (replace `corpus_name`).  Unless you have new kinds of fields and a very different `vrt` file structure from the ones already used in altlab, you can:
   - Copy one of the existing `yaml` files, for example, `cp corpora/wolfart_ahenakew.yaml corpora/corpus_name.yaml`
   - Change the `id`, `title`, and `description` fields.
   - Select a `folder` for the corpus in the `default` mode. Make sure the folder exists in the `modes/default.yaml` file.
   - If you want search to immediately work on this corpus, add the corpus to the list  in `modes/default.yaml` (One could also create different modes)
2. Make sure that the `backend/import_vrt.sh` file allows CWB to understand your specific `vrt` format:
   - If you are just following the `wolfart_ahenakew.vrt` format, there's nothing you need to do.  Currently, the format is:
     ```
     -P word -P lemma -P analysis -P deps -P gloss -S sentence:0+id -S paragraph -S text:2+id+lang+title+author -S corpus:0+id -U ""
     ```
     This format means that there are 5 p-attributes (word, lemma, analysis, deps, gloss) and 4 xml-based s-attributes (sentence, paragraph, text, corpus).  The `text` tag can be used recursively up to a nesting of 2, the others cannot.  `sentence` and `corpus` XML tags can have an `id` attribute, while `text` tags can have `id`, `lang`, `title`, and `author` attributes.
   - If your format is different, generate a special case for the script to handle it. follow the example of the following lines:
     ```
     if [ "$NAME" = "bloomfield" ]; then
        VRT_FORMAT_STRUCTURE="-P word -P lemma -P analysis -P deps -P gloss -S sentence:0+id -S paragraph -S text:2+id+title+author -S corpus:0+id+lang -U \"\""
     fi
     ```
   Verify that the fields you previously described in `corpora/corpus_name.yaml` match the structure of the `vrt` file. The `yaml` file assumes mappings of the form `cwb_field_name: attribute_presentation_yaml`. The keys correspond to the name of the field *in the CWB registry file for the corpus*, and the values correspond to the file name of an attribute description *in the `attributes/` folder of this repository, or otherwise completely inlined*.
3. Commit your changes to this repo and push
### Deploy the new changes to the server
1. Deploy your repo changes:
   ```
         you@local $ ssh altlab.dev
     you@altlab-gw $ ssh altlab-itw
    you@altlab-itw $ sudo -i -u korp
   korp@altlab-itw $ cd korp-config/docker/
   korp@altlab-itw $ ./deploy
   ```
2. Load the new corpus `.vrt` into CWB and the korp backend using the appropriate script:
   ```
   korp@altlab-itw $ docker-compose exec korp-backend bash /app/first_load_corpus.sh corpus_name
   ```
