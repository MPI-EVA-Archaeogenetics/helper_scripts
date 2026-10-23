
# Track Autorun Status

This is a script to gather the processing status of a sample within the departmental pipeline and output a table summarizing it. 

Usage:
```
bash helper_scripts/trackStatus_autorun/processingChecker.sh -l <sample_list.txt> -o <output_tag> [ -i <IBD_version>]
```

Input list (-l) is a one-per-line list of IDs at any Pandora processing level (from individual to sequencing). 
The script will fetch everything downstream of the indicated ID. 

Example:
```
TFP001
PINT011
TFP002.A0101
TFP003.A0101.SG1.1
```

`-o` is the output prefix (any)
`-i` the IBD release version to check. If not specified, the latest one will be assumed.


----- 

Example of an output from the command: 
```
$ bash processingChecker.sh -l list_exa
mple -o example -i v14.0
Processing sample TFP002.A0101.TF1.1 (6/6))
Report generated: example.tsv
```

Output table: 
```
Sample	Autorun_Processed	Autorun_date	Deduplication_date	DateLastMultiqc	ATLAS	ATLAS_lastMod	Coverage_inATLAS	Coverage_Autorun	Imputed	Imputation_date	GTL_output_published	GTL_output_date	IBD_v14.0	InMasterVCF_v14.0	covATLAS-covAutorun
PINT011.A0101.RM1.1	YES	2026-01-11	2026-01-14	2026-01-19	YES	2026-02-04	320469	203707	YES	2026-09-08	YES	2026-09-08	NO	NO	116762
PINT011.A0101.SG1.1	YES	2025-07-22	2025-10-01	2026-04-13	YES	2026-02-04	320469	801	YES	2026-09-08	YES	2026-09-08	NO	NO	319668
TFP001.A0101.SG1.1	YES	2026-04-11	2026-05-13	2026-05-13	YES	2023-03-13	979037	269600	YES	2026-09-08	YES	2026-09-08	YES	YES	709437
TFP001.A0101.SG1.2	YES	2026-05-11	2026-05-13	2026-05-13	YES	2023-03-13	979037	269600	YES	2026-09-08	YES	2026-09-08	YES	YES	709437
TFP001.A0101.TF1.1	YES	2022-02-27	2025-09-08	2025-09-10	YES	2023-03-13	979037	737131	YES	2026-09-08	YES	2026-09-08	YES	YES	241906
TFP002.A0101.TF1.1	YES	2022-02-27	2024-12-08	2024-12-08	YES	2023-03-13	78369	48708	YES	2026-09-08	YES	2026-09-08	NO	YES	29661
```

Output table has one line per sequencing run. Each column provides information about one of the steps. 
```
Autorun_Processed: YES/NO the sample was picked up by Autorun_eager
Autorun_date: yyyy-mm-dd when Autorun_eager picked up the sample for the last time
Deduplication_date: yyyy-mm-dd when Autorun_eager produced the most recent deduplicated bam file
DateLastMultiqc: : yyyy-mm-dd when Autorun_eager produced the most recent Multiqc html file
ATLAS: YES/NO the sample was picked up and fully run through ATLAS genotype likelihoods estimation
ATLAS_lastMod: yyyy-mm-dd when the sample's genotype likelihoods were last updated
Coverage_inATLAS: number of 1240k positions covered in the ATLAS merged bam file
Coverage_Autorun: highest number of 1240k positions covered among the Autorun_eager deduplicated bam files
Imputed: YES/NO the sample was picked up and fully run through GLIMPSE imputation
Imputation_date: yyyy-mm-dd when the sample's imputated vcf file was last updated
```

## TIPS
This tool's main function is to check from the user's side if a sample correctly run through the departmental pipeline step. To do so, two possible checks can be applied: 
- If the order of the updates is correct (imputation youngest, Autorun_eager oldest), then all the sequencing outputs for the given sample should have be included in the latest imputation
- If the coverages are comparable between the estimations from the ATLAS pipeline and Autorun_eager, and the imputation date is more recent than the ATLAS processing date, then possibly all the genetic data should have been included