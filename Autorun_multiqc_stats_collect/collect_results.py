#!/usr/bin/env python3
import json
import argparse
import sys
import os
import subprocess
from typing import List, Dict, Union
try:
    import pyEager
except ImportError:
    print("Installing required package 'pyEager'", file=sys.stderr)
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pyEager"])
    import pyEager
import pandas as pd
import numpy as np
try:
    import pyPandoraHelper as pH
except ImportError:
    print("Installing required package 'pyPandoraHelper'", file=sys.stderr)
    subprocess.check_call([sys.executable, "-m", "pip", "install", "/mnt/archgen/tools/helper_scripts/py_helpers/"])
    import pyPandoraHelper as pH

VERSION = "1.6.0"

def get_individual_library_stats(mqc_data, main_id_dict=None):
    ## Read json file, and combine relevant sample and library stats into a dictionary
    with open(mqc_data, "r") as json_file:
        data = json.load(json_file)
    ## Create empty dicts and lists to store results
    results = {}
    sample_stats = {}
    library_stats = {}
    sample_libraries = []
    ## Loop through json file and store relevant stats in dicts
    for key in data["report_saved_raw_data"]["multiqc_general_stats"].keys():
        ## If the key contains a '.', it is a library stat, otherwise it is a sample stat
        if len(key.split(".")) > 1:
            ## eager 2.5.0 also has split by UDG for some stats. we want to compile these together, as each library can only have one udg treatment.
            ## By splitting by '_udg', we can get the library ID, and then add the attributes to the library dict for both cases.
            try:
                ## If the library key is already in the dict, add the attributes to it
                library_stats[key.split("_udg")[0]].update(
                    data["report_saved_raw_data"]["multiqc_general_stats"][key]
                )
            except KeyError:
                ## If the library ID doesn't exist in the dict, create it
                library_stats[key.split("_udg")[0]] = data["report_saved_raw_data"][
                    "multiqc_general_stats"
                ][key]
                sample_libraries.append(
                    key
                )  ## Keep track of library IDs for later. Only add it if its new.
            ## Not actually needed since key.split("_udg")[0] will always be the Library_ID
            # else:
            #     ## Library key is actual Library_ID
            #     try:
            #         ## If the library key is already in the dict, add the attributes to it
            #         library_stats[key].update(data["report_saved_raw_data"]["multiqc_general_stats"][key])
            #     except KeyError:
            #         ## If the library ID doesn't exist in the dict, create it
            #         library_stats[key] = data["report_saved_raw_data"]["multiqc_general_stats"][key]
            #     sample_libraries.append(key)  ## Keep track of library IDs for later
        else:
            sample_stats[key] = data["report_saved_raw_data"]["multiqc_general_stats"][
                key
            ]

    for library in sample_libraries:
        ## Get the sample ID from the library ID, to ensure ss libs get ss sample stats
        ## Use update instead of union to work with python <3.9
        compiled_results = {}
        ind_id           = pH.get_ind_id(library, keep_ss_suffix=True)
        ind_id_no_ss     = pH.get_ind_id(library, keep_ss_suffix=False)
        if ind_id.endswith("_ss"):
            ind_suffix = "_ss"
        else:
            ind_suffix = ""
        try:
            compiled_results.update(sample_stats[ind_id])
        except KeyError as e:
            if ind_id_no_ss in main_id_dict.keys():
                compiled_results.update(sample_stats[main_id_dict[ind_id_no_ss]+ind_suffix])
            else:
                raise Exception(
                    f"Unknown sample for library: {library}."
                ) from e
        compiled_results.update(library_stats[library])
        results[library] = compiled_results
        ## Old implementation using dict union.
        ## Use union of attributes to combine dicts. attributes from the library level will overwrite any that exist in the sample level. Should be no overlap, but good to note.
        # results[library] = dict(sample_stats[library.split('.')[0]] | library_stats[library])

    ## Standardise column naming across multiqc versions
    results = standardise_column_names(results)
    ## results is a dict of dicts, with the library ID as the key. The value then contains a dict of the combined stats for that library/sample.
    return results


## Some column names changed from 2.4.5 to 2.5.0, so we need to standardise the names of these columns across both versions.
def standardise_column_names(collected_stats):
    #    OLD NAME                                                                               NEW NAME
    #    DamageProfiler_mqc-generalstats-damageprofiler-3_Prime1                                mapDamage_mqc-generalstats-mapdamage-mapdamage_3_Prime1
    #    DamageProfiler_mqc-generalstats-damageprofiler-3_Prime2                                mapDamage_mqc-generalstats-mapdamage-mapdamage_3_Prime2
    #    DamageProfiler_mqc-generalstats-damageprofiler-5_Prime1                                mapDamage_mqc-generalstats-mapdamage-mapdamage_5_Prime1
    #    DamageProfiler_mqc-generalstats-damageprofiler-5_Prime2                                mapDamage_mqc-generalstats-mapdamage-mapdamage_5_Prime2
    #    DamageProfiler_mqc-generalstats-damageprofiler-mean_readlength                         NA
    #    DamageProfiler_mqc-generalstats-damageprofiler-median                                  NA
    #    DamageProfiler_mqc-generalstats-damageprofiler-std                                     NA
    #    endorSpy_mqc-generalstats-endorspy-endogenous_dna                                      base endorSpy_mqc-generalstats-base_endorspy-endogenous_dna
    #    endorSpy_mqc-generalstats-endorspy-endogenous_dna_post                                 base endorSpy_mqc-generalstats-base_endorspy-endogenous_dna_post
    #    nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_ML_SE             base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method1_ML_SE
    #    nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_ML_estimate       base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method1_ML_estimate
    #    nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_MOM_SE            base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method1_MOM_SE
    #    nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_MOM_estimate      base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method1_MOM_estimate
    #    nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_ML_SE             base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method2_ML_SE
    #    nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_ML_estimate       base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method2_ML_estimate
    #    nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_MOM_SE            base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method2_MOM_SE
    #    nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_MOM_estimate      base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method2_MOM_estimate
    #    nuclear_contamination_mqc-generalstats-nuclear_contamination-Num_SNPs                  base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Num_SNPs
    #    snp_coverage_mqc-generalstats-snp_coverage-Covered_Snps                                base snp_coverage_mqc-generalstats-base_snp_coverage-Covered_Snps
    #    snp_coverage_mqc-generalstats-snp_coverage-Total_Snps                                  base snp_coverage_mqc-generalstats-base_snp_coverage-Total_Snps
    new_attributes = {
        "dmg_3p_1": "N/A",
        "dmg_3p_2": "N/A",
        "dmg_5p_1": "N/A",
        "dmg_5p_2": "N/A",
        "mean_read_length": "N/A",
        "median_read_length": "N/A",
        "read_length_std_dev": "N/A",
        "endogenous": "N/A",
        "endogenous_post": "N/A",
        "nuc_cont_m1_ml_se": "N/A",
        "nuc_cont_m1_ml_est": "N/A",
        "nuc_cont_m1_mom_se": "N/A",
        "nuc_cont_m1_mom_est": "N/A",
        "nuc_cont_m2_ml_se": "N/A",
        "nuc_cont_m2_ml_est": "N/A",
        "nuc_cont_m2_mom_se": "N/A",
        "nuc_cont_m2_mom_est": "N/A",
        "nuc_cont_snps": "N/A",
        "snps_covered": "N/A",
        "snps_total": "N/A",
    }

    old_names = {
        "dmg_3p_1": "DamageProfiler_mqc-generalstats-damageprofiler-3_Prime1",
        "dmg_3p_2": "DamageProfiler_mqc-generalstats-damageprofiler-3_Prime2",
        "dmg_5p_1": "DamageProfiler_mqc-generalstats-damageprofiler-5_Prime1",
        "dmg_5p_2": "DamageProfiler_mqc-generalstats-damageprofiler-5_Prime2",
        "mean_read_length": "DamageProfiler_mqc-generalstats-damageprofiler-mean_readlength",
        "median_read_length": "DamageProfiler_mqc-generalstats-damageprofiler-median",
        "read_length_std_dev": "DamageProfiler_mqc-generalstats-damageprofiler-std",
        "endogenous": "endorSpy_mqc-generalstats-endorspy-endogenous_dna",
        "endogenous_post": "endorSpy_mqc-generalstats-endorspy-endogenous_dna_post",
        "nuc_cont_m1_ml_se": "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_ML_SE",
        "nuc_cont_m1_ml_est": "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_ML_estimate",
        "nuc_cont_m1_mom_se": "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_MOM_SE",
        "nuc_cont_m1_mom_est": "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_MOM_estimate",
        "nuc_cont_m2_ml_se": "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_ML_SE",
        "nuc_cont_m2_ml_est": "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_ML_estimate",
        "nuc_cont_m2_mom_se": "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_MOM_SE",
        "nuc_cont_m2_mom_est": "nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_MOM_estimate",
        "nuc_cont_snps": "nuclear_contamination_mqc-generalstats-nuclear_contamination-Num_SNPs",
        "snps_covered": "snp_coverage_mqc-generalstats-snp_coverage-Covered_Snps",
        "snps_total": "snp_coverage_mqc-generalstats-snp_coverage-Total_Snps",
    }

    new_names = {
        "dmg_3p_1": "mapDamage_mqc-generalstats-mapdamage-mapdamage_3_Prime1",
        "dmg_3p_2": "mapDamage_mqc-generalstats-mapdamage-mapdamage_3_Prime2",
        "dmg_5p_1": "mapDamage_mqc-generalstats-mapdamage-mapdamage_5_Prime1",
        "dmg_5p_2": "mapDamage_mqc-generalstats-mapdamage-mapdamage_5_Prime2",
        "endogenous": "base endorSpy_mqc-generalstats-base_endorspy-endogenous_dna",
        "endogenous_post": "base endorSpy_mqc-generalstats-base_endorspy-endogenous_dna_post",
        "nuc_cont_m1_ml_se": "base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method1_ML_SE",
        "nuc_cont_m1_ml_est": "base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method1_ML_estimate",
        "nuc_cont_m1_mom_se": "base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method1_MOM_SE",
        "nuc_cont_m1_mom_est": "base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method1_MOM_estimate",
        "nuc_cont_m2_ml_se": "base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method2_ML_SE",
        "nuc_cont_m2_ml_est": "base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method2_ML_estimate",
        "nuc_cont_m2_mom_se": "base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method2_MOM_SE",
        "nuc_cont_m2_mom_est": "base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Method2_MOM_estimate",
        "nuc_cont_snps": "base nuclear_contamination_mqc-generalstats-base_nuclear_contamination-Num_SNPs",
        "snps_covered": "base snp_coverage_mqc-generalstats-base_snp_coverage-Covered_Snps",
        "snps_total": "base snp_coverage_mqc-generalstats-base_snp_coverage-Total_Snps",
    }

    ## Starting with all NAs, add in any values that exist in either the old dict or the new dict
    for library in collected_stats:
        new_stats = collected_stats[library]
        new_stats.update(new_attributes)  ## Add all new attributed with NAs
        ## Deal with older versions of multiqc
        try:
            for name, old_name in old_names.items():
                new_stats[name] = new_stats[old_name]
        except KeyError:
            pass
        ## Deal with newer versions of multiqc
        try:
            for name, new_name in new_names.items():
                new_stats[name] = new_stats[new_name]
        except KeyError:
            pass
        # print("library:", library, "stats", new_stats, sep="\n")
        collected_stats[library] = new_stats
    return collected_stats


def timestamp_diff_in_sec(file1, file2):
    ## Get the creation time of each file
    for f in [file1, file2]:
        ## Check that the files indeed exist
        if not os.path.exists(f) or not os.path.isfile(f):
            raise FileNotFoundError

    timestamp1 = os.path.getmtime(file1)
    timestamp2 = os.path.getmtime(file2)

    ## Return the modification time difference in seconds
    return abs(timestamp1 - timestamp2)


def files_are_consistent(mqc_data, mqc_html, skip_check=False):
    ## Check if the multiqc data and html files are up to date
    ## Complain if the difference is more than 1 minute (should be less than a second, but give some leeway for network/filesystem latency etc.)
    if timestamp_diff_in_sec(mqc_data, mqc_html) > 60:
        return skip_check
    return True

def read_eager_tsv(file_path) -> map:
    '''
    Reads the contents of an eager input TSV into a dictionary with the column names as keys.
    '''
    l = file_path.readlines()
    headers = l[0].strip().split('\t')
    return map(lambda row: dict(zip(headers, row.split('\t'))), l[1:])

def get_eager_tsv_data(path: str ='', columns: List[str] = []) -> Union[Dict[str, Dict[str, str]], None]:
    '''
    Reads the contents of an eager input TSV and returns a dictionary with the Library_ID as key a
    dictionary containing the requested column and values as values.
    '''
    ## Check that path is a file and exists
    if not os.path.isfile(path):
        print(f"File {path} not found. Exiting.")
        return None
    
    ## Remove any column names that are not allowed
    ##  Note: Lane, Colour_Chemistry, SeqType columns do not make much sense to collect when dealing with library-level results.
    allowed_column_requests = ["Sample_Name", "Lane", "Colour_Chemistry", "SeqType", "Organism", "Strandedness", 
                        "UDG_Treatment", "R1", "R2", "BAM"]
    collect_me = []
    for col in columns:
        if col not in allowed_column_requests:
            print(f"Column name {col} is not allowed. Skipping.")
        else:
            collect_me.append(col)
    
    ## If no columns were requested, return None
    if not collect_me:
        print("No columns were requested. Exiting.")
        return None
    
    else:
        collected_library_stats = {}
        with open(path, 'r') as f:
            for row in read_eager_tsv(f):
                row_results = {}
                for col in collect_me:
                    row_results[col] = row[col]
                ## This will always overwrite later entries with the same Library_ID, but that is fine for now.
                collected_library_stats[row["Library_ID"]] = row_results
        return collected_library_stats

def read_main_id_list(file_path: str) -> Dict[str, str]:
    '''
    Reads a file with a header and two columns, where the first column is the Pandora Full individual ID and the second column is the Pandora Main individual ID.
    '''
    if not os.path.isfile(file_path):
        print(f"File {file_path} not found. Exiting.")
        return None
    if not os.path.exists(file_path):
        print(f"File {file_path} does not exist. Exiting.")
        return None
    
    main_id_dict = {}
    with open(file_path, 'r') as f:
        for line in f:
            if line.startswith("#") or not line.strip():
                continue
            if line.startswith("Full_Individual_Id\tMain_Individual_Id"):
                continue
            fields = line.strip().split('\t')
            main_id_dict[fields[0]] = fields[1]
    return main_id_dict

def main():
    ## Column order same as old script.
    output_columns = {
        "Covered_SNPs_on_1240K": "snps_covered",
        "Total_SNPs_on_1240K": "snps_total",
        "Nr_of_input_reads": "Samtools Flagstat (pre-samtools filter)_mqc-generalstats-samtools_flagstat_pre_samtools_filter-flagstat_total",
        "Nr_of_mapped_reads": "Samtools Flagstat (pre-samtools filter)_mqc-generalstats-samtools_flagstat_pre_samtools_filter-mapped_passed",
        "Nr_of_input_reads_over_30bp": "Samtools Flagstat (post-samtools filter)_mqc-generalstats-samtools_flagstat_post_samtools_filter-flagstat_total",
        "%_Endogenous_DNA": "endogenous",
        "Nr_of_mapped_reads_over_30bp": "Samtools Flagstat (post-samtools filter)_mqc-generalstats-samtools_flagstat_post_samtools_filter-mapped_passed",
        "%_Endogenous_DNA_over_30bp": "endogenous_post",
        "Proportion_of_duplicate_reads": "Picard_mqc-generalstats-picard-PERCENT_DUPLICATION",
        "Damage_5'_bp1": "dmg_5p_1",
        "Damage_5'_bp2": "dmg_5p_2",
        "Damage_3'_bp1": "dmg_3p_1",
        "Damage_3'_bp2": "dmg_3p_2",
        "Mean_read_length": "mean_read_length",
        "Median_read_length": "median_read_length",
        "Nr_mtDNA_reads": "mtnucratio_mqc-generalstats-mtnucratio-mtreads",
        "Mean_mt_coverage": "mtnucratio_mqc-generalstats-mtnucratio-mt_cov_avg",
        "mt_to_nuclear_read_ratio": "mtnucratio_mqc-generalstats-mtnucratio-mt_nuc_ratio",
        "Nr_of_unique_mapped_reads": "QualiMap_mqc-generalstats-qualimap-mapped_reads",
        "Mean_fold_coverage": "QualiMap_mqc-generalstats-qualimap-mean_coverage",
        "Median_fold_coverage": "QualiMap_mqc-generalstats-qualimap-median_coverage",
        "%_of_genome_covered_by_at_least_1_read": "QualiMap_mqc-generalstats-qualimap-1_x_pc",
        "%_of_genome_covered_by_at_least_2_reads": "QualiMap_mqc-generalstats-qualimap-2_x_pc",
        "%_of_genome_covered_by_at_least_3_reads": "QualiMap_mqc-generalstats-qualimap-3_x_pc",
        "%_of_genome_covered_by_at_least_4_reads": "QualiMap_mqc-generalstats-qualimap-4_x_pc",
        "%_of_genome_covered_by_at_least_5_reads": "QualiMap_mqc-generalstats-qualimap-5_x_pc",
        "%_GC_of_unique_reads": "QualiMap_mqc-generalstats-qualimap-avg_gc",
        "Read_length_std_dev": "read_length_std_dev",
        "Mean_fold_coverage_on_nuclear_genome": "mtnucratio_mqc-generalstats-mtnucratio-nuc_cov_avg",
        "Nr_nuclearDNA_reads": "mtnucratio_mqc-generalstats-mtnucratio-nucreads",
        # "%_of_mapped_reads": "QualiMap_mqc-generalstats-qualimap-percentage_aligned",
        "Nr_of_reads_total": "QualiMap_mqc-generalstats-qualimap-total_reads",
        "Qualimap_General_error_rate": "QualiMap_mqc-generalstats-qualimap-general_error_rate",
        "StdErr_of_X_relative_coverage": "SexDetErrmine_mqc-generalstats-sexdeterrmine-RateErrX",
        "StdErr_of_Y_relative_coverage": "SexDetErrmine_mqc-generalstats-sexdeterrmine-RateErrY",
        "Relative_coverage_on_X_chromosome": "SexDetErrmine_mqc-generalstats-sexdeterrmine-RateX",
        "Relative_coverage_on_Y_chromosome": "SexDetErrmine_mqc-generalstats-sexdeterrmine-RateY",
        "Nr_SNPs_used_in_contamination_estimation": "nuc_cont_snps",
        "Nuclear_contamination_M1_ML": "nuc_cont_m1_ml_est",
        "Nuclear_contamination_M1_ML_Error": "nuc_cont_m1_ml_se",
        "Nuclear_contamination_M1_MOM": "nuc_cont_m1_mom_est",
        "Nuclear_contamination_M1_MOM_Error": "nuc_cont_m1_mom_se",
        "Nuclear_contamination_M2_ML": "nuc_cont_m2_ml_est",
        "Nuclear_contamination_M2_ML_Error": "nuc_cont_m2_ml_se",
        "Nuclear_contamination_M2_MOM": "nuc_cont_m2_mom_est",
        "Nuclear_contamination_M2_MOM_Error": "nuc_cont_m2_mom_se",
        "UDG_Treatment": "UDG_Treatment",
        "Strandedness": "Strandedness",
    }

    parser = argparse.ArgumentParser(
        description="This is a script for collecting a batch of library-level multiqc stats for individuals for which capture or shotgun data exists."
    )
    parser.add_argument(
        "-r",
        "--root_output_path",
        help="The root directory where the eager output lies. Within this directory there should be the structure <analysis_type>/<site_id>/<individual_id>/*.",
        required=False,
        default="/mnt/archgen/Autorun_eager/eager_outputs/",
    )
    parser.add_argument(
        "-i",
        "--input",
        help="Input file with a list of individuals for which capture or shotgun data exists.",
        required=True,
    )
    parser.add_argument(
        "-o",
        "--output",
        help="Output file with a list of individuals for which capture or shotgun data exists.",
        required=True,
    )
    parser.add_argument(
        "-a",
        "--analysis_type",
        help="Analysis type: capture or shotgun. Options are: SG, TF, RP, RM. Defaults to TF.",
        default="TF",
        choices=["SG", "TF", "RP", "RM"],
    )
    parser.add_argument(
        "--skip_check",
        help="By default, results from runs where the consistency of the MultiQC output files cannot be verified will be skipped. Use this flag to disable this behaviour. Only recommended if you know why the check failed to begin with.",
        default=False,
        action="store_true",
    )
    parser.add_argument(
        "--main_id_list",
        metavar="FILE",
        help="A file with two columns, where the first column is the Pandora Full individual ID and the second column is the Pandora Main individual ID. This is used to map Full IDs to Main IDs.",
        default="/mnt/archgen/tools/helper_scripts/assets/pandora_tables/pandora_main_ind_id_list.txt",
        required=False,
    )
    parser.add_argument(
        "-H",
        "--header",
        help="Use human-readable header, instead of original MultiQC table header.",
        default=False,
        action="store_true",
    )
    parser.add_argument(
        "-v",
        "--version",
        action="version",
        version="%(prog)s {}".format(VERSION),
        help="Print the version and exit.",
    )
    args = parser.parse_args()

    ## Print version info to stderr on runtime
    print("## {}: {}".format(parser.prog, VERSION), file=sys.stderr)

    ## Loudly declare when the script is run with the --skip_check flag
    if args.skip_check:
        print(
            "WARNING: Skipping the check for consistency between MultiQC data and report files. This may result in the inclusion of outdated results, or runtime errors!",
            file=sys.stderr,
        )

    ## Read in list of individuals
    with open(args.input, "r") as f:
        individuals = [pH._remove_suffix(_) for _ in f.read().splitlines()]
        print(
            "Found {} individuals in input file.".format(len(individuals)), file=sys.stderr
        )

    ## Read list of main IDs
    main_id_dict = read_main_id_list(args.main_id_list)

    ## Iterate over individuals and collect stats
    collected_stats = {}
    skip_count = 0
    for ind in individuals:
        ## Set input file path
        mqc_data = "{}/{}/{}/{}/multiqc/multiqc_data/multiqc_data.json".format(
            args.root_output_path, args.analysis_type, pH.get_site_id(ind), ind
        )

        ## Infer path to MQC report
        report_path = mqc_data.replace(
            "multiqc_data/multiqc_data.json", "multiqc_report.html"
        )

        ## Infer path to nf-core/eager input TSV
        ##  Making the assumption that the eager_inputs and eager_outputs are in the same directory as the root_output_path
        tsv_path = "{}/../eager_inputs/{}/{}/{}/{}.tsv".format(
            args.root_output_path, args.analysis_type, pH.get_site_id(ind), ind, ind
        )

        ## Get stats
        try:
            ## First, ensure the MQC data are consistent with the report
            if files_are_consistent(mqc_data, report_path, args.skip_check):
                collected_stats.update(get_individual_library_stats(mqc_data, main_id_dict))
                ## Read in eager input TSV data and add to the collected stats
                tsv_dat = get_eager_tsv_data(tsv_path, ["UDG_Treatment", "Strandedness"])
                for library in tsv_dat:
                    collected_stats[library].update(tsv_dat[library])
            else:
                print(
                    f"WARNING: There is a large difference in the creation time between the MultiQC data file '{mqc_data}' and the corresponding HTML '{report_path}'. Skipping.",
                    file=sys.stderr,
                )
                skip_count += 1
                continue
        except FileNotFoundError:
            print(
                "No multiqc data found for individual {}. Skipping.".format(ind),
                file=sys.stderr,
            )
            skip_count += 1
            continue
        print("Collected stats for individual {}.".format(ind), file=sys.stderr)
    
    ## Collect mapdamage results where needed, and include read length distribution info in the output
    md_results_dirs = []
    for library in collected_stats:
        try:
            if 'mapDamage_mqc-generalstats-mapdamage-mapdamage_3_Prime1' in collected_stats[library]:
                md_results_dirs.append(
                    '{}/{}/{}/{}/mapdamage/results_{}_rmdup'.format(
                        args.root_output_path,
                        args.analysis_type,
                        pH.get_site_id(library),
                        pH.get_ind_id(library),
                        library
                        )
                    )
        except FileNotFoundError:
            print("Warning: Could not generate read length distribution information for library: {} ".format(library), file=sys.stderr)
            continue
    md_results = pyEager.collect_mapdamage_results(md_results_dirs)
    for result_folder_name in md_results:
        try:
            ## Take the basename of the file, then remove "results_" and "_rmdup" to get the library name
            library = result_folder_name.split('/')[-1].replace("_rmdup", "").replace("results_", "")
            collected_stats[library]['mean_read_length']    = md_results[result_folder_name]['summary_stats']['mean_readlength'].iloc[0]
            collected_stats[library]['median_read_length']  = md_results[result_folder_name]['summary_stats']['median'].iloc[0]
            collected_stats[library]['read_length_std_dev'] = md_results[result_folder_name]['summary_stats']['std'].iloc[0]
        except KeyError:
            print("Warning: Could not incorporate read length distribution information for library: {} ".format(library), file=sys.stderr)
            continue

    ## Print number of skipped individuals to stderr if any
    if skip_count > 0:
        print(
            "WARNING: No data was found for {} individuals!".format(skip_count),
            file=sys.stderr,
        )

    ## Print results to output file
    with open(args.output, "w") as f:
        ## Add header
        if args.header:
            print("Sample", *output_columns.keys(), sep="\t", file=f)
        else:
            print("Sample", *output_columns.values(), sep="\t", file=f)
        ## Add data
        for library in sorted(collected_stats.keys()):
            try:
                print(
                    library,
                    *[
                        collected_stats[library][column]
                        for column in output_columns.values()
                    ],
                    sep="\t",
                    file=f,
                )
            except KeyError as e:
                raise Exception(
                    f"Encountered an error while trying to print stats for library: {library}."
                ) from e

        ## Add footer with version info
        flags = ""
        if args.skip_check:
            flags += " --skip_check"
        if args.header:
            flags += " --header"

        print(f"## {parser.prog}: {VERSION}", file=f)
        print(
            f"## Command: {parser.prog} -i {args.input} -o {args.output} -a {args.analysis_type}{flags}",
            file=f,
        )

if __name__ == "__main__":
    main()
