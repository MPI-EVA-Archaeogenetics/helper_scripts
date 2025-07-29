# Autorun_multiqc_stats_collect

This is a script for collecting a batch of individuals' multiqc stats.

Put all the sample ID (e.g. AGV001) into one text, one ID per line. An example of the input sample list file:
```
ABC001
ABC002
ABC003
```

Then run the script like below:
```bash
collect_results.py -i input.tsv -o collected_data.txt
```

The following command will instead pull the SG results, and use a human-readable header line for the output table.
```bash
collect_results.py -i input.tsv -o collected_data.txt -a SG -H
```

Below is an explanation of the parameters:
```
usage: collect_results.py [-h] [-r ROOT_OUTPUT_PATH] -i INPUT -o OUTPUT [-a {SG,TF,RP,RM}] [--skip_check] [--main_id_list FILE] [-H] [-v]

This is a script for collecting a batch of library-level multiqc stats for individuals for which capture or shotgun data exists.

options:
  -h, --help            show this help message and exit
  -r ROOT_OUTPUT_PATH, --root_output_path ROOT_OUTPUT_PATH
                        The root directory where the eager output lies. Within this directory there should be the structure <analysis_type>/<site_id>/<individual_id>/*.
  -i INPUT, --input INPUT
                        Input file with a list of individuals for which capture or shotgun data exists.
  -o OUTPUT, --output OUTPUT
                        Output file with a list of individuals for which capture or shotgun data exists.
  -a {SG,TF,TM,RP,RM,IM,YC}, --analysis_type {SG,TF,TM,RP,RM,IM,YC}
                        Analysis type: capture or shotgun. Options are: SG, TF, TM, RP, RM, IM, YC. Defaults to TF.
  --skip_check          By default, results from runs where the consistency of the MultiQC output files cannot be verified will be skipped. Use this flag to disable this behaviour. Only recommended if
                        you know why the check failed to begin with.
  --main_id_list FILE   A file with two columns, where the first column is the Pandora Full individual ID and the second column is the Pandora Main individual ID. This is used to map Full IDs to Main
                        IDs.
  -H, --header          Use human-readable header, instead of original MultiQC table header.
  -v, --version         Print the version and exit.
```

The ordering of the columns in the output table is consistent. By default, the original column headers of the data are kept. If the user specifies the `-H` option, the headers are instead replaced by some more human-readable headers, that might be better suited for e.g. to displaying the results to collaborators. 

In cases where there is more than one library for a sample, any sample-level statistics will be duplicated for each library.

The script will collect TF data by default. This behaviour can be changed by specifying `-a SG`, to instead collect SG data.

As a quick check that the results being loaded are up to date, the script will check that the MultiQC output files were created within a minute of each other. If the script detects that the output files are not consistent, it will skip the results from that run. This behaviour can be disabled by specifying `--skip_check`. This is only recommended if you know why the check failed to begin with, as you might otherwise be incorporating outdated results.
