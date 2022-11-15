#!/bin/bash
VERSION="0.1.0"


## Helptext function
function Helptext() {
  echo -ne "\t usage: $0 [options] (-i input.tsv) (-o output.txt)\n\n"
  echo -ne "This is a script for collecting a batch of one-library-individuals' multiqc stats for capture data.\n\n"
  echo -ne "Options:\n"
  echo -ne "-i, --input\t\tAn input tsv file with one column containing the Pandora individual ID (e.g. ABC001).\n"
  echo -ne "-o, --output\t\tThe table of the collected data.\n"
  echo -ne "-h, --help\t\tPrint this text and exit.\n"
  echo -ne "-v, --version \t\tPrint version and exit.\n"
}

## Print messages to stderr
function errecho() { echo $* 1>&2 ;}


## Parse CLI args.
TEMP=`getopt -q -o hvi:o: --long help,version,input:,output: -n 'collect_results.sh' -- "$@"`
eval set -- "$TEMP"

## parameter default
of1=""
inf=""

	
## Read in CLI arguments
while true ; do
  case "$1" in
    -i|--input) inf="$2"; shift 2;;
    -o|--output) of1="$2"; shift 2;;
    -h|--help) Helptext; exit 0 ;;
    -v|--version) echo ${VERSION}; exit 0;;
    --) break ;;
    *) echo -e "invalid option provided: $1.\n"; Helptext; exit 1;;
  esac
done

if [[ ${inf} == '' ]]; then
  errecho "[collect_results.sh]: No input file was provided."
  exit 1
elif [[ ! -f ${inf} ]]; then
  errecho "[collect_results.sh]: Input file does not exist."
  exit 1
fi

if [[ ${of1} == '' ]]; then
  errecho "[collect_results.sh]: No output file prefix was provided."
  exit 1
fi



hv="Sample	snp_coverage_mqc-generalstats-snp_coverage-Covered_Snps	snp_coverage_mqc-generalstats-snp_coverage-Total_Snps	Samtools_Flagstat_(pre-samtools_filter)_mqc-generalstats-samtools_flagstat_pre_samtools_filter-flagstat_total	Samtools_Flagstat_(pre-samtools_filter)_mqc-generalstats-samtools_flagstat_pre_samtools_filter-mapped_passed	Samtools_Flagstat_(post-samtools_filter)_mqc-generalstats-samtools_flagstat_post_samtools_filter-flagstat_total	endorSpy_mqc-generalstats-endorspy-endogenous_dna	Samtools_Flagstat_(post-samtools_filter)_mqc-generalstats-samtools_flagstat_post_samtools_filter-mapped_passed	endorSpy_mqc-generalstats-endorspy-endogenous_dna_post	Picard_mqc-generalstats-picard-PERCENT_DUPLICATION	DamageProfiler_mqc-generalstats-damageprofiler-5_Prime1	DamageProfiler_mqc-generalstats-damageprofiler-5_Prime2	DamageProfiler_mqc-generalstats-damageprofiler-3_Prime1	DamageProfiler_mqc-generalstats-damageprofiler-3_Prime2	DamageProfiler_mqc-generalstats-damageprofiler-mean_readlength	DamageProfiler_mqc-generalstats-damageprofiler-median	mtnucratio_mqc-generalstats-mtnucratio-mtreads	mtnucratio_mqc-generalstats-mtnucratio-mt_cov_avg	mtnucratio_mqc-generalstats-mtnucratio-mt_nuc_ratio	QualiMap_mqc-generalstats-qualimap-mapped_reads	QualiMap_mqc-generalstats-qualimap-mean_coverage	QualiMap_mqc-generalstats-qualimap-median_coverage	QualiMap_mqc-generalstats-qualimap-1_x_pc	QualiMap_mqc-generalstats-qualimap-2_x_pc	QualiMap_mqc-generalstats-qualimap-3_x_pc	QualiMap_mqc-generalstats-qualimap-4_x_pc	QualiMap_mqc-generalstats-qualimap-5_x_pc	QualiMap_mqc-generalstats-qualimap-avg_gc	DamageProfiler_mqc-generalstats-damageprofiler-std	mtnucratio_mqc-generalstats-mtnucratio-nuc_cov_avg	mtnucratio_mqc-generalstats-mtnucratio-nucreads	QualiMap_mqc-generalstats-qualimap-percentage_aligned	QualiMap_mqc-generalstats-qualimap-total_reads	QualiMap_mqc-generalstats-qualimap-general_error_rate	SexDetErrmine_mqc-generalstats-sexdeterrmine-RateErrX	SexDetErrmine_mqc-generalstats-sexdeterrmine-RateErrY	SexDetErrmine_mqc-generalstats-sexdeterrmine-RateX	SexDetErrmine_mqc-generalstats-sexdeterrmine-RateY	nuclear_contamination_mqc-generalstats-nuclear_contamination-Num_SNPs	nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_MOM_estimate	nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_MOM_SE	nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_ML_estimate	nuclear_contamination_mqc-generalstats-nuclear_contamination-Method1_ML_SE	nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_MOM_estimate	nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_MOM_SE	nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_ML_estimate	nuclear_contamination_mqc-generalstats-nuclear_contamination-Method2_ML_SE"
echo ${hv} > ${of1}
for P in $(cat $inf); do 
    tfn1="/mnt/archgen/Autorun_eager/eager_outputs/TF/*/"${P}"/multiqc/multiqc_data/multiqc_general_stats.txt"
    X=($(cat ${tfn1} | tail -1 | awk '{print $1":"}' ))  
    Y=($(cat ${tfn1} | head -2 | tail -1 | awk '{print $2":"$3":"}')) 
    Z=($(cat ${tfn1} | tail -1 | awk '{print $2":"$3":"$4":"$5":"$6":"$7":"$8":"$9":"$10":"$11":"$12":"$13":"$14":"$15":"$16":"$17":"$18":"$19":"$20":"$21":"$22":"$23":"$24":"$25":"$26":"$27":"$28":"$29":"$30":"$31":"$32":"$33":"$34":"$35":"$36":"$37":"$38":"$39":"$40":"$41":"$42":"$43":"$44":"$45":"$46":"$47":"$48}')) 
    echo ${X}${Y}${Z} | sed s/":"/" "/g >> ${of1}
    echo ${P}" is processed" 
done
