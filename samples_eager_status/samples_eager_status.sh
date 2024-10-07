#!/usr/bin/env bash
VERSION="0.1.0"


## Helptext function
function Helptext() {
  echo -ne "\t usage: $0 [options] (-i input.txt)\n\n"
  echo -ne "This is a script for checking if Autorun_eager has completed and run succesfully for a list of individuals IDs.\n\n"
  echo -ne "Options:\n"
  echo -ne "-i, --input\t\tAn input txt file with one column containing the Pandora individual ID (e.g. ABC001).\n"
  echo -ne "-h, --help\t\tPrint this text and exit.\n"
  echo -ne "-v, --version \t\tPrint version and exit.\n"
}

## Print messages to stderr
function errecho() { echo $* 1>&2 ;}


## Parse CLI args.
TEMP=`getopt -q -o hvi: --long help,version,input: -n 'samples_eager_status.sh' -- "$@"`
eval set -- "$TEMP"

## parameter default
inf=""
	
## Read in CLI arguments
while true ; do
  case "$1" in
    -i|--input) inf="$2"; shift 2;;
    -h|--help) Helptext; exit 0 ;;
    -v|--version) echo ${VERSION}; exit 0;;
    --) break ;;
    *) echo -e "invalid option provided: $1.\n"; Helptext; exit 1;;
  esac
done

if [[ ${inf} == '' ]]; then
  errecho "[samples_eager_status.sh]: No input file was provided."
  exit 1
elif [[ ! -f ${inf} ]]; then
  errecho "[samples_eager_status.sh]: Input file does not exist."
  exit 1
fi

while read line; do
	iid=($(echo ${line} | awk '{print $1}'))
	num=($(grep -n ${iid} /mnt/archgen/Autorun_eager/*_Autorun_eager_queue.txt | cut -f 1 -d " " | sed s/":cd"/""/g | rev | cut -f 1 -d ":" | rev | tail -1))
	run=($(grep -n ${iid} /mnt/archgen/Autorun_eager/*_Autorun_eager_queue.txt | cut -f 1 -d " " | sed s/":cd"/""/g | rev | cut -f 2- -d ":" | cut -f 1 -d "/" | rev | tail -1))
	status=($(exec 2>&- grep "Pipeline completed" /mnt/archgen/Autorun_eager/array_Logs/${run}/AE_spawner*txt.o*.${num} | awk '{OFS = "-"; print $2,$3,$4}'))
	echo -e ${iid}"\t"${status}
done < <(cat ${inf})

