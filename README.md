# Configuration files for korp

There are several extra configuration files required to make korp work locally.

## Configuration requirements

Besides cloning this repo at some location, you need to also ensure
that your `korp-backend/config.py` has access to the location of this
repo through the following configuration line:

```
CORPUS_CONFIG_DIR = "/patho/to/repo/korp-config/"
```
