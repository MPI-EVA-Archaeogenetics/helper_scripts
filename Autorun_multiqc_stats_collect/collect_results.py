#!/usr/bin/env python3
VERSION='0.1.0'
import json
import argparse
import sys
# from collections import OrderedDict

def get_individual_library_stats(mqc_data) :
  ## Read json file, and combine relevant sample and library stats into a dictionary
  with open(mqc_data, 'r') as json_file:
    data = json.load(json_file)
  ## Create empty dicts and lists to store results
  results = {}
  sample_stats = {}
  library_stats = {}
  sample_libraries = []
  ## Loop through json file and store relevant stats in dicts
  for key in data['report_saved_raw_data']['multiqc_general_stats'].keys():
    ## If the key contains a '.', it is a library stat, otherwise it is a sample stat
    if len(key.split('.')) > 1:
      library_stats[key] = data['report_saved_raw_data']['multiqc_general_stats'][key]
      sample_libraries.append(key) ## Keep track of library IDs for later
    else:
      sample_stats[key] = data['report_saved_raw_data']['multiqc_general_stats'][key]
  
  for library in sample_libraries:
    ## Get the sample ID from the library ID, to ensure ss libs get ss sample stats
    ## Use union of attributes to combine dicts. attributes from the library level will overwrite any that exist in the sample level. Should be no overlap, but good to note.
    results[library] = dict(sample_stats[library.split('.')[0]] | library_stats[library])
  
  ## results is a dict of dicts, with the library ID as the key. The value then contains a dict of the combined stats for that library/sample.
  return results

## Hard-coded values
root_output_path="/mnt/archgen/Autorun_eager/eager_outputs/"

## This is my preferred column order, but might break existing implementations of the old script.
# output_columns={
#   "Covered_SNPs_on_1240K"                    : "snp_coverage_mqc-generalstats-snp_coverage-Covered_Snps",
#   "Total_SNPs_on_1240K"                      : "snp_coverage_mqc-generalstats-snp_coverage-Total_Snps",
#   "Relative_coverage_on_X_chromosome"        : "SexDetErrmine_mqc-generalstats-sexdeterrmine-RateX",
#   "Relative_coverage_on_Y_chromosome"        : "SexDetErrmine_mqc-generalstats-sexdeterrmine-RateY",
#   "StdErr_of_X_relative_coverage"            : "SexDetErrmine_mqc-generalstats-sexdeterrmine-RateErrX",
#   "StdErr_of_Y_relative_coverage"            : "SexDetErrmine_mqc-generalstats-sexdeterrmine-RateErrY",
#   "Number_of_mapped_reads"                   : "QualiMap_mqc-generalstats-qualimap-mapped_reads",
#   "Mean_fold_coverage"                       : "QualiMap_mqc-generalstats-qualimap-mean_coverage",
#   "Median_fold_coverage"                     : "QualiMap_mqc-generalstats-qualimap-median_coverage",
#   "%_of_genome_covered_by_at_least_1_read"   : "QualiMap_mqc-generalstats-qualimap-1_x_pc",
#   "%_of_genome_covered_by_at_least_2_reads"  : "QualiMap_mqc-generalstats-qualimap-2_x_pc",
#   "%_of_genome_covered_by_at_least_3_reads"  : "QualiMap_mqc-generalstats-qualimap-3_x_pc",
#   "%_of_genome_covered_by_at_least_4_reads"  : "QualiMap_mqc-generalstats-qualimap-4_x_pc",
#   "%_of_genome_covered_by_at_least_5_reads"  : "QualiMap_mqc-generalstats-qualimap-5_x_pc",
#   "%_GC_of_unique_reads"                     : "QualiMap_mqc-generalstats-qualimap-avg_gc",
#   "%_of_mapped_reads"                        : "QualiMap_mqc-generalstats-qualimap-percentage_aligned",
#   "Number_of_reads_total"                    : "QualiMap_mqc-generalstats-qualimap-total_reads",
#   "Qualimap_General_error_rate"              : "QualiMap_mqc-generalstats-qualimap-general_error_rate",
#   "Number_of_input_reads"                    : "Samtools Flagstat (pre-samtools filter)_mqc-generalstats-samtools_flagstat_pre_samtools_filter-flagstat_total",
#   "Number_of_input_mapped_reads"             : "Samtools Flagstat (pre-samtools filter)_mqc-generalstats-samtools_flagstat_pre_samtools_filter-mapped_passed",
#   "Number_of_input_reads_over_30bp"          : "Samtools Flagstat (post-samtools filter)_mqc-generalstats-samtools_flagstat_post_samtools_filter-flagstat_total",
#   "Number_of_mapped_reads_over_30bp"         : "Samtools Flagstat (post-samtools filter)_mqc-generalstats-samtools_flagstat_post_samtools_filter-mapped_passed",
#   "%_Endogenous_DNA"                         : "endorSpy_mqc-generalstats-endorspy-endogenous_dna",
#   "%_Endogenous_DNA_over_30bp"               : "endorSpy_mqc-generalstats-endorspy-endogenous_dna_post",
#   "%_Duplicates"                             : "Picard_mqc-generalstats-picard-PERCENT_DUPLICATION",
#   "Damage_5'_bp1"                            : "DamageProfiler_mqc-generalstats-damageprofiler-5_Prime1",
#   "Damage_5'_bp2"                            : "DamageProfiler_mqc-generalstats-damageprofiler-5_Prime2",
#   "Damage_3'_bp1"                            : "DamageProfiler_mqc-generalstats-damageprofiler-3_Prime1",
#   "Damage_3'_bp2"                            : "DamageProfiler_mqc-generalstats-damageprofiler-3_Prime2",
#   "Mean_read_length"                         : "DamageProfiler_mqc-generalstats-damageprofiler-mean_readlength",
#   "Median_read_length"                       : "DamageProfiler_mqc-generalstats-damageprofiler-median",
#   "Nr_mtDNA_reads"                           : "mtnucratio_mqc-generalstats-mtnucratio-mtreads",
#   "Mean_mt_coverage"                         : "mtnucratio_mqc-generalstats-mtnucratio-mt_cov_avg",
#   "mt_to_nuclear_read_ratio"                 : "mtnucratio_mqc-generalstats-mtnucratio-mt_nuc_ratio",
#   "Read_length_std_dev"                      : "DamageProfiler_mqc-generalstats-damageprofiler-std",
#   "Mean_fold_coverage_on_nuclear_genome."    : "mtnucratio_mqc-generalstats-mtnucratio-nuc_cov_avg",
#   "Nr_nuclearDNA_reads"                      : "mtnucratio_mqc-generalstats-mtnucratio-nucreads",
#   "Nr_SNPs_used_in_contamination_estimation" : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Num_SNPs",
#   "Nuclear_contamination_M1_MOM"             : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_MOM_estimate",
#   "Nuclear_contamination_M1_MOM_Error"       : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_MOM_SE",
#   "Nuclear_contamination_M1_ML"              : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_ML_estimate",
#   "Nuclear_contamination_M1_ML_Error"        : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_ML_SE",
#   "Nuclear_contamination_M2_MOM"             : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_MOM_estimate",
#   "Nuclear_contamination_M2_MOM_Error"       : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_MOM_SE",
#   "Nuclear_contamination_M2_ML"              : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_ML_estimate",
#   "Nuclear_contamination_M2_ML_Error"        : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_ML_SE",
# }

## Column order same as old script.
output_columns={
  "Covered_SNPs_on_1240K"                    : "snp_coverage_mqc-generalstats-snp_coverage-Covered_Snps" ,
  "Total_SNPs_on_1240K"                      : "snp_coverage_mqc-generalstats-snp_coverage-Total_Snps" ,
  "Number_of_input_reads"                    : "Samtools Flagstat (pre-samtools filter)_mqc-generalstats-samtools_flagstat_pre_samtools_filter-flagstat_total" ,
  "Number_of_mapped_reads"                   : "Samtools Flagstat (pre-samtools filter)_mqc-generalstats-samtools_flagstat_pre_samtools_filter-mapped_passed" ,
  "Number_of_input_reads_over_30bp"          : "Samtools Flagstat (post-samtools filter)_mqc-generalstats-samtools_flagstat_post_samtools_filter-flagstat_total" ,
  "%_Endogenous_DNA"                         : "endorSpy_mqc-generalstats-endorspy-endogenous_dna" ,
  "Number_of_mapped_reads_over_30bp"         : "Samtools Flagstat (post-samtools filter)_mqc-generalstats-samtools_flagstat_post_samtools_filter-mapped_passed" ,
  "%_Endogenous_DNA_over_30bp"               : "endorSpy_mqc-generalstats-endorspy-endogenous_dna_post" ,
  "%_Duplicates"                             : "Picard_mqc-generalstats-picard-PERCENT_DUPLICATION" ,
  "Damage_5'_bp1"                            : "DamageProfiler_mqc-generalstats-damageprofiler-5_Prime1" ,
  "Damage_5'_bp2"                            : "DamageProfiler_mqc-generalstats-damageprofiler-5_Prime2" ,
  "Damage_3'_bp1"                            : "DamageProfiler_mqc-generalstats-damageprofiler-3_Prime1" ,
  "Damage_3'_bp2"                            : "DamageProfiler_mqc-generalstats-damageprofiler-3_Prime2" ,
  "Mean_read_length"                         : "DamageProfiler_mqc-generalstats-damageprofiler-mean_readlength" ,
  "Median_read_length"                       : "DamageProfiler_mqc-generalstats-damageprofiler-median" ,
  "Nr_mtDNA_reads"                           : "mtnucratio_mqc-generalstats-mtnucratio-mtreads" ,
  "Mean_mt_coverage"                         : "mtnucratio_mqc-generalstats-mtnucratio-mt_cov_avg" ,
  "mt_to_nuclear_read_ratio"                 : "mtnucratio_mqc-generalstats-mtnucratio-mt_nuc_ratio" ,
  "Number_of_mapped_reads_total"             : "QualiMap_mqc-generalstats-qualimap-mapped_reads" ,
  "Mean_fold_coverage"                       : "QualiMap_mqc-generalstats-qualimap-mean_coverage" ,
  "Median_fold_coverage"                     : "QualiMap_mqc-generalstats-qualimap-median_coverage" ,
  "%_of_genome_covered_by_at_least_1_read"   : "QualiMap_mqc-generalstats-qualimap-1_x_pc" ,
  "%_of_genome_covered_by_at_least_2_reads"  : "QualiMap_mqc-generalstats-qualimap-2_x_pc" ,
  "%_of_genome_covered_by_at_least_3_reads"  : "QualiMap_mqc-generalstats-qualimap-3_x_pc" ,
  "%_of_genome_covered_by_at_least_4_reads"  : "QualiMap_mqc-generalstats-qualimap-4_x_pc" ,
  "%_of_genome_covered_by_at_least_5_reads"  : "QualiMap_mqc-generalstats-qualimap-5_x_pc" ,
  "%_GC_of_unique_reads"                     : "QualiMap_mqc-generalstats-qualimap-avg_gc" ,
  "Read_length_std_dev"                      : "DamageProfiler_mqc-generalstats-damageprofiler-std" ,
  "Mean_fold_coverage_on_nuclear_genome."    : "mtnucratio_mqc-generalstats-mtnucratio-nuc_cov_avg" ,
  "Nr_nuclearDNA_reads"                      : "mtnucratio_mqc-generalstats-mtnucratio-nucreads" ,
  "%_of_mapped_reads"                        : "QualiMap_mqc-generalstats-qualimap-percentage_aligned" ,
  "Number_of_reads_total"                    : "QualiMap_mqc-generalstats-qualimap-total_reads" ,
  "Qualimap_General_error_rate"              : "QualiMap_mqc-generalstats-qualimap-general_error_rate" ,
  "StdErr_of_X_relative_coverage"            : "SexDetErrmine_mqc-generalstats-sexdeterrmine-RateErrX" ,
  "StdErr_of_Y_relative_coverage"            : "SexDetErrmine_mqc-generalstats-sexdeterrmine-RateErrY" ,
  "Relative_coverage_on_X_chromosome"        : "SexDetErrmine_mqc-generalstats-sexdeterrmine-RateX" ,
  "Relative_coverage_on_Y_chromosome"        : "SexDetErrmine_mqc-generalstats-sexdeterrmine-RateY" ,
  "Nr_SNPs_used_in_contamination_estimation" : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Num_SNPs" ,
  "Nuclear_contamination_M1_MOM"             : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_MOM_estimate" ,
  "Nuclear_contamination_M1_MOM_Error"       : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_MOM_SE" ,
  "Nuclear_contamination_M1_ML"              : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_ML_estimate" ,
  "Nuclear_contamination_M1_ML_Error"        : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_ML_SE" ,
  "Nuclear_contamination_M2_MOM"             : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_MOM_estimate" ,
  "Nuclear_contamination_M2_MOM_Error"       : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_MOM_SE" ,
  "Nuclear_contamination_M2_ML"              : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_ML_estimate" ,
  "Nuclear_contamination_M2_ML_Error"        : "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_ML_SE" ,
}

parser = argparse.ArgumentParser(description='This is a script for collecting a batch of library-level multiqc stats for individuals for which capture or shotgun data exists.')
parser.add_argument('-i', '--input', help='Input file with a list of individuals for which capture or shotgun data exists.' ,required=True)
parser.add_argument('-o', '--output', help='Output file with a list of individuals for which capture or shotgun data exists.', required=True)
parser.add_argument('-a', '--analysis_type', help='Analysis type: capture or shotgun. Options are: SG, TF. Defaults to TF.', default="TF", choices=["SG", "TF"])
parser.add_argument('-H', '--header', help='Use human-readable header, instead of original MultiQC table header.', default=False, action='store_true')
parser.add_argument("-v", "--version", action='version', version="%(prog)s {}".format(VERSION), help="Print the version and exit.")
args = parser.parse_args()

## Read in list of individuals
with open(args.input, 'r') as f:
  individuals = f.read().splitlines()
  print("Found {} individuals in input file.".format(len(individuals)), file=sys.stderr)

## Iterate over individuals and collect stats
collected_stats = {}
skip_count = 0
for ind in individuals:
  ## Set input file path
  mqc_data = "{}/{}/{}/{}/multiqc/multiqc_data/multiqc_data.json".format(root_output_path, args.analysis_type, ind[0:3], ind)
  
  ## Get stats
  try:
    collected_stats = collected_stats | get_individual_library_stats(mqc_data)
  except FileNotFoundError:
    print("No multiqc data found for individual {}. Skipping.".format(ind), file=sys.stderr)
    skip_count += 1
    continue
  print("Collected stats for individual {}.".format(ind), file=sys.stderr)

## Print number of skipped individuals to stderr if any
if skip_count > 0:
  print("WARNING: No data was found for {} individuals!".format(skip_count), file=sys.stderr)

## Print results to output file
with open(args.output, 'w') as f:
  ## Add header
  if args.header:
    print ("Sample", *output_columns.keys(), sep="\t", file=f)
  else:
    print ("Sample", *output_columns.values(), sep="\t", file=f)
  ## Add data
  for library in sorted(collected_stats.keys()):
    print(library, *[collected_stats[library][column] for column in output_columns.values()], sep="\t", file=f)
