#!/usr/bin/env bash
VERSION="0.1.0"

## Colours for printing to terminal
Yellow=$(tput sgr0)'\033[1;33m' ## Yellow normal face
Red=$(tput sgr0)'\033[1;31m' ## Red normal face
Normal=$(tput sgr0)

## Helptext function
function Helptext() {
  echo -ne "\t usage: $0 [options] (-i input.tsv | -p pandora_id )\n\n"
  echo -ne "This script will pull metadata for the specified individual-level poseidon packages from Pandora and Autorun_eager, check for changes, and update teh poseidon package, if needed.\n\n"
  echo -ne "Options:\n"
  echo -ne "-i, --input\t\tAn input tsv file containing the Pandora individual IDs (e.g. ABC001) whose packages you want to update, one per line.\n\t\t\t\tOne individual/data_type combination per line. Both dsDNA and ssDNA data for an individual will be pulled if available.\n"
  echo -ne "-p, --pandora_id\t\tAlternative input method. A Pandora individual ID can be provided directly from the command line. Can be provided multiple times. Mutually exclusive with -i/--input\n"
  echo -ne "-d, --dry_run\t\t Follow normal operations, but do not overwrite live package, leaving the completed package in the temporary directory for manual checks.\n"
  echo -ne "-h, --help\t\tPrint this text and exit.\n"
  echo -ne "-v, --version \t\tPrint version and exit.\n"
}

## Print messages to stderr
function errecho() { echo -e $* 1>&2 ;}

## Function to check failure and stop execution
function check_fail() { if [[ $1 != 0 ]]; then errecho "${Red}Execution failed at ${2}${Normal}"; exit 3; fi;}

## Parse CLI args.
TEMP=`getopt -q -o hvdi:p: --long help,dry_run,version,input:,pandora_id: -n 'update_poseidon_metadata.sh' -- "$@"`
eval set -- "$TEMP"

## Parameter defaults
dry_run="FALSE"
input_tsv_fn=''
tsv_provided='FALSE'
contamination_snp_cutoff="100"  ## Provided to fill_in_janno.R
ss_suffix="_ss"                 ## Provided to fill_in_janno.R
geno_ploidy='haploid'           ## Provided to fill_in_janno.R
date_stamp="$(date +'%D')"

## Print helptext and exit when no option is provided.
if [[ "${#@}" == "1" ]]; then
  Helptext
  exit 0
fi

## Read in CLI arguments
while true ; do
  case "$1" in
    -i|--input) input_tsv_fn="$2"; tsv_provided='TRUE'; shift 2;;
    -p|--pandora_id) pandora_ids+=("$2"); shift 2;;
    -h|--help) Helptext; exit 0 ;;
    -v|--version) echo ${VERSION}; exit 0;;
    -d|--dry_run) dry_run="TRUE"; shift ;;
    --) break ;;
    *) echo -e "invalid option provided.\n"; Helptext; exit 1;;
  esac
done

## Validate parameters and combinations
if [[ "${tsv_provided}" == 'TRUE' && ${#pandora_ids[@]} != 0 ]]; then
  errecho "Error: Options '--input' and '--pandora_id' are mutually exclusive. Halting execution."
  exit 1
elif [[ "${tsv_provided}" == 'TRUE' && ! -f ${input_tsv_fn} ]]; then
  errecho "File not found: ${input_tsv_fn}"
  exit 2
fi

if [[ "${tsv_provided}" == 'TRUE' ]]; then
  ## Read in tsv input into bash array of ind IDs. Use only first column, just in case.
  pandora_ids=($(awk '{print $1}' ${input_tsv_fn}))
fi

## Hard-coded paths
autorun_root_dir='/mnt/archgen/Autorun_eager/'
sc_janno_fill="${autorun_root_dir}/scripts/fill_in_janno.R"
sc_update_ind="${autorun_root_dir}/scripts/update_dataset_from_janno.R"
root_input_dir='/mnt/archgen/Autorun_eager/eager_outputs' ## Directory should include subdirectories for each analysis type (TF/SG) and sub-subdirectories for each site and individual.
root_output_dir='/mnt/archgen/Autorun_eager/poseidon_packages' ## Directory that includes data type, site ID and ind ID subdirs.
root_temp_dir="${autorun_root_dir}/.tmp/update_poseidon_metadata/"
cred_file="${autorun_root_dir}/.eva_credentials"
trident_path="/r1/people/srv_autoeager/bin/trident-1.1.4.2"
mkdir -p ${root_temp_dir}

for ind_id in ${pandora_ids[@]}; do
  package_dir="${root_output_dir}/TF/${ind_id:0:3}/${ind_id}/"
  if [[ ! -d ${package_dir} ]]; then
    errecho "${Red}A poseidon package does not exist for individual: ${ind_id}${Normal}"
    exit 3
  fi

  ## Create temp dir to put package in for updating, so users dont get a half-baked package.
  TEMPDIR=$(mktemp -d ${root_temp_dir}/${ind_id}_XXXXXXXX)
  mkdir ${TEMPDIR}/${ind_id}
  errecho "${Yellow}[update_poseidon_metadata.sh]: Pulling metadata for: ${ind_id}${Normal}"
  ${sc_janno_fill} \
    -j ${package_dir}/${ind_id}.janno \
    -i ${ind_id} \
    -c ${cred_file} \
    -s ${contamination_snp_cutoff} \
    -p ${geno_ploidy} \
    -S ${ss_suffix} \
    -o ${TEMPDIR}/${ind_id}/${ind_id}.janno

  check_fail $? 'STEP 1: Janno fill-in.'
  
  ## Check for difference in md5sum of jannos
  original_md5=$(md5sum ${package_dir}/${ind_id}.janno | awk '{print $1}')
  new_md5=$(md5sum ${TEMPDIR}/${ind_id}/${ind_id}.janno | awk '{print $1}')

  if [[ ${new_md5} == ${original_md5} ]]; then
    errecho "${Yellow}No change detected in metadata.${Normal}"
  else
    ## Copy over poseidon package files excluding the dataset
    errecho "${Yellow}## Copying package backbone ##${Normal}"
    ## Create poseidon package directory and populate with existsing files plus new janno
    cp ${package_dir}/${ind_id}.bib    ${TEMPDIR}/${ind_id}/
    cp ${package_dir}/CHANGELOG.md     ${TEMPDIR}/${ind_id}/
    cp ${package_dir}/POSEIDON.yml     ${TEMPDIR}/${ind_id}/
    cp ${package_dir}/${ind_id}.geno   ${TEMPDIR}/${ind_id}/
    cp ${package_dir}/${ind_id}.snp    ${TEMPDIR}/${ind_id}/
    cp ${package_dir}/${ind_id}.ind    ${TEMPDIR}/${ind_id}/
    cp ${package_dir}/AE_version.txt   ${TEMPDIR}/${ind_id}/

    ## Update ind file from janno, just in case
    errecho "${Yellow}## Updating indFile ##${Normal}"
    ${sc_update_ind} -y ${TEMPDIR}/${ind_id}/POSEIDON.yml
    check_fail $? "STEP 2: Mirror janno info to indFile. ${TEMPDIR}/${ind_id}"

    ## Update package CHANGELOG
    errecho "${Yellow}## Updating package changelog ##${Normal}"
    ${trident_path} update \
      -d ${TEMPDIR}/${ind_id}/ \
      --logText "${date_stamp} helper_scripts/update_poseidon_metadata.sh ${VERSION}" \
      --versionComponent Patch
    check_fail $? "STEP 3: Trident update. ${TEMPDIR}/${ind_id}"

    ## Validate new package
    errecho "${Yellow}## Validating package ##${Normal}"
    ${trident_path} validate -d ${TEMPDIR}/${ind_id}/
    check_fail $? "STEP 4: Package valiadtion. ${TEMPDIR}/${ind_id}"

    if [[ ${dry_run} == "TRUE" ]]; then
      errecho "${Yellow}DRY RUN: The created package can be found in: ${TEMPDIR}/${ind_id}${Normal}"
    else
      ## Move updated pacakge to live and remove temp files
      errecho "${Yellow}## Moving temp package to live ##${Normal}"
      mv ${TEMPDIR}/${ind_id} ${package_dir}
      rmdir ${TEMPDIR}
    fi
  fi
done
