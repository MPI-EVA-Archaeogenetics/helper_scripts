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
usage: collect_results.py [-h] -i INPUT -o OUTPUT [-a {SG,TF}] [-H] [-v]

This is a script for collecting a batch of library-level multiqc stats for individuals for which capture or shotgun data exists.

optional arguments:
  -h, --help            show this help message and exit
  -i INPUT, --input INPUT
                        Input file with a list of individuals for which capture or shotgun data exists.
  -o OUTPUT, --output OUTPUT
                        Output file with a list of individuals for which capture or shotgun data exists.
  -a {SG,TF,RP,RM}, --analysis_type {SG,TF,RP,RM}
                        Analysis type: capture or shotgun. Options are: SG, TF, RP, RM. Defaults to TF.
  --skip_check          By default, results from runs where the consistency of the MultiQC output files 
                        cannot be verified will be skipped. Use this flag to disable this behaviour.
                        Only recommended if you know why the check failed to begin with.
  -H, --header          Use human-readable header, instead of original MultiQC table header.
  -v, --version         Print the version and exit.
```

The ordering of the columns in the output table is consistent. By default, the original column headers of the data are kept. If the user specifies the `-H` option, the headers are instead replaced by some more human-readable headers, that might be better suited for e.g. to displaying the results to collaborators. 

In cases where there is more than one library for a sample, any sample-level statistics will be duplicated for each library.

The script will collect TF data by default. This behaviour can be changed by specifying `-a SG`, to instead collect SG data.

As a quick check that the results being loaded are up to date, the script will check that the MultiQC output files were created within a minute of each other. If the script detects that the output files are not consistent, it will skip the results from that run. This behaviour can be disabled by specifying `--skip_check`. This is only recommended if you know why the check failed to begin with, as you might otherwise be incorporating outdated results.
