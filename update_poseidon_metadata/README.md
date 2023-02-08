# Update poseidon package metadata from pandora and eager results.

This script allows end users to force update the annotation table (`.janno`) of a set of poseidon packages published by Autorun_eager, to incorporate changes made to the Pandora entries for these individuals.
Specifically, the script will re-generate a janno file for the requested package and look for changes between the newly-created file and the existing janno for the package. If any changes are found:
- the new janno file replaces the original one
- the package gets re-validated
- a log entry is added to the package `CHANGELOG.md`
- the package version is bumped (at the patch level)
- the new version of the package is published to the live Autorun_eager poseidon package directory, replacing the existing package.

## Running `update_poseidon_metadata/update_poseidon_metadata.sh`

Running `update_poseidon_metadata.sh` with the `-h` or `--help` options will print usage information and a lost of the available options:
```
   usage: ./update_poseidon_metadata.sh [options] (-i input.tsv | -p pandora_id [ -p pandora_id2 ... ] )

This script will pull metadata for the specified individual-level poseidon packages from Pandora and Autorun_eager, check for changes, and update teh poseidon package, if needed.

Options:
-i, --input         An input tsv file containing the Pandora individual IDs (e.g. ABC001) whose packages you want to update, one per line.
                      One individual/data_type combination per line. Both dsDNA and ssDNA data for an individual will be pulled if available.
                      Mutually exclusive with -p/--pandora_id
-p, --pandora_id    Alternative input method. A Pandora individual ID can be provided directly from the command line. Can be provided multiple times.
                      Mutually exclusive with -i/--input
-d, --dry_run       Follow normal operations, but do not overwrite live package, leaving the completed package in the temporary directory for manual checks.
-h, --help          Print this text and exit.
-v, --version       Print version and exit.
```

There are two ways to specify which packages should be updated:

- You can either provide a list of pandora individual IDs in a file (one per line) using the `-i/--input` option. The script will then attempt to update the metadata for each of the specified individual-level packages.
- Or, you can provide Pandora individual IDs directly on the command line using the `-p/--pandora_id` option. This option can be provided multiple times to update multiple packages at the same time.

The `-d/--dry_run` option can be used to create an updated package (if necessary) but avoid publishing it to the live Autorun_eager poseidon package directory. This can be used to manually check that everything looks right in the resulting `janno` file, before publishing the updated package to the live directory. If you are planning to make incremental changes to Pandora while updating packages, this is the way to go, to avoid applying multiple patch updates to the package that could be condensed into a single update.

Finally, as with all `helper_scripts`, the `-v/--version` option can be used to print the script version. This version string is also added to the log entries created in the `CHANGELOG.md` of a poseidon package on update.