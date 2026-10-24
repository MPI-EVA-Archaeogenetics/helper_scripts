#!/usr/bin/env bash

v="1.0.0"

#get options
sampleList=""
tag=""
IBDversion=""

usage() {
    echo "Usage: $0 -l <sample_list.txt> -o <output_tag> [-i <IBD_version>]"
    echo "       $0 --sampleList <sample_list.txt> --out-prefix <output_tag> [--IBDversion <IBD_version>]"
}

if [[ "$1" == "meow" ]]; then
    echo "    /\_____/\ "
    echo "   /  o   o  \ "
    echo "  ( ==  ^  == ) "
    echo "   )         ( "
    echo "  (           ) "
    echo " ( (  )   (  ) ) "
    echo "(__(__)___(__)__) "
    exit 0
fi

## Parse CLI args. This will parse the args cleanly so that a user can provide them with/without spaces etc, but the script will still work it out.
TEMP=`getopt -q -o l:o:i:hv --long sample-list:,sampleList:,out-prefix:,IBDversion:,ibd-version,help,version -n "$0" -- "$@"`
eval set -- "$TEMP"

while true; do
    case "$1" in
        -l|--sampleList|--sample-list)
            if (($# < 2)); then
                echo "Error: $1 requires a value." >&2
                usage >&2
                exit 1
            fi
            sampleList=$2
            shift 2
            ;;
        -o|--out-prefix)
            if (($# < 2)); then
                echo "Error: $1 requires a value." >&2
                usage >&2
                exit 1
            fi
            tag=$2
            shift 2
            ;;
        -i|--IBDversion|--ibd-version)
            if (($# < 2)); then
                echo "Error: $1 requires a value." >&2
                usage >&2
                exit 1
            fi
            IBDversion=$2
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            echo "processingChecker.sh version ${v}"
            exit 0
            ;;
        -*)
            echo "Error: unknown option $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            if [[ -z "$sampleList" ]]; then
                sampleList=$1
            elif [[ -z "$tag" ]]; then
                tag=$1
            elif [[ -z "$IBDversion" ]]; then
                IBDversion=$1
            else
                echo "Error: unexpected argument $1" >&2
                usage >&2
                exit 1
            fi
            break
            ;;
    esac
done

if [[ -z "$sampleList" || -z "$tag" ]]; then
    usage >&2
    exit 1
fi


#if IBDversion is empty, se it to the latest one 
if [ -z "$IBDversion" ]; then
    IBDversion=$(ls /mnt/archgen/ibd_release/ | grep -E '^v[0-9]+\.[0-9]+$' | sort -V | tail -1)
    echo "No IBD version provided. Using latest version: $IBDversion"
fi

#if IBDversion does not start with v, add it
if [[ ! $IBDversion =~ ^v ]]; then
    IBDversion="v${IBDversion}"
fi

autoResultsDirs=/mnt/archgen/Autorun/Results
autoEagerDir=/mnt/archgen/Autorun_eager/eager_outputs
IBDdir=/mnt/archgen/ibd_release/${IBDversion}
pH="/mnt/archgen/tools/helper_scripts/py_helpers/pyPandoraHelper/pyPandoraHelper.py"

#if IBD directory does not exist, print error and exit
if [ ! -d "$IBDdir" ]; then
    echo "Error: IBD directory $IBDdir does not exist. Please check the IBD version provided."
    exit 1
fi


cat /mnt/archgen/Autorun/Pandora_Tables/{Human_RM.txt,Human_RP.txt,Human_Shotgun.txt,Human_TM.txt,Human_1240k.txt} \
        | cut -f1 \
        | sort \
        | uniq \
        > /mnt/archgen/DAG_GL/list_seqs.txt


#make header
echo -e "Sample\tAutorun_Processed\tAutorun_date\tDeduplication_date\tDateLastMultiqc\tATLAS\tATLAS_lastMod\tCoverage_inATLAS\tCoverage_Autorun\tImputed\tImputation_date\tGTL_output_published\tGTL_output_date\tIBD_${IBDversion}\tInMasterVCF_${IBDversion}\tcovATLAS-covAutorun" > $tag.tsv

#Run throgh the scripts
progress=0
total=$(grep -f $sampleList /mnt/archgen/DAG_GL/list_seqs.txt| wc -l)

for sample in $(cat /mnt/archgen/DAG_GL/list_seqs.txt | grep -f $sampleList); do
    progress=$((progress + 1))
    printf "\rProcessing sample %s (%d/%d)" "$sample" "$progress" "$total"

    basename=$(${pH} -g ind_id ${sample})
    site=$(${pH} -g site_id ${sample})
    library=$(${pH} -g library_id ${sample} | cut -f 2 -d ".")
    cap=$(${pH} -g capture_id ${sample} | cut -f 3 -d ".")
    captype=$(${pH} -g capture_id ${sample} | cut -f 3 -d "." | cut -c 1,2)
    seq=$(${pH} -g sequencing_id ${sample} | cut -f 4 -d ".")


    #specify pandora table to use
    if [ $captype == "SG" ]; then table="Human_Shotgun.txt"
    elif [ $captype == "TF" ]; then table="Human_1240k.txt"
    else table=Human_${captype}.txt
    fi

    #check if processed by Autorun
    AutorunDir=$(grep $sample /mnt/archgen/Autorun/Pandora_Tables/$table | cut -f2)
    AutorunProcessed=$(ls $AutorunDir/${sample}.bam 2>/dev/null | wc -l)
    dateAutorunProcessed=$(date -r $AutorunDir/${sample}.bam +%Y-%m-%d 2>/dev/null)

    #Check if deduplication, genotyping and multiqc steps are done
    mostRecDedup=$(ls ${autoEagerDir}/${captype}/${site}/${basename}/deduplication/${basename}*/${basename}*rmdup.bam  2>/dev/null | tail -1)
    dateLastDedup=$(date -r $mostRecDedup +%Y-%m-%d)
    mostRecGeno=$(ls ${autoEagerDir}/${captype}/${site}/${basename}/genotyping/pileupcaller*.geno \
                        -tr 2>/dev/null | tail -1)
    dateLastGeno=$(date -r $mostRecGeno +%Y-%m-%d 2>/dev/null)
    mostRecGenoPresent=$(ls ${autoEagerDir}/${captype}/${site}/${basename}/genotyping/pileupcaller*.geno 2>/dev/null | wc -l)
    coverageAutorun=$(cat ${autoEagerDir}/${captype}/${site}/${basename}/genotyping/*_coverage.txt 2>/dev/null \
                    | awk '{print $2}' | grep -v "SNPs_Covered" \
                    | tr "\n" "\," | sed 's/\,$//g')
    higherCoverage=$(echo $coverageAutorun | tr "," "\n" | sort -n | tail -1)
    multiqcPresent=$(ls ${autoEagerDir}/${captype}/${site}/${basename}/multiqc/multiqc_report.html 2>/dev/null | wc -l)
    dateLastMultiqc=$(date -r ${autoEagerDir}/${captype}/${site}/${basename}/multiqc/multiqc_report.html +%Y-%m-%d 2>/dev/null)

    #check if the genotyping pipeline picked the sample up
    GTfilePres=$(ls /mnt/archgen/DAG_GL/MLVCFS/${basename}/${basename}_MaximumLikelihood.vcf.gz 2>/dev/null | wc -l)
    GTlastMod=$(date -r /mnt/archgen/DAG_GL/MLVCFS/${basename}/${basename}_MaximumLikelihood.vcf.gz +%Y-%m-%d 2>/dev/null )
    coverageGTL=$(cut -f 4 /mnt/archgen/DAG_GL/MLVCFS/${basename}/${basename}.coverages.txt 2>/dev/null | tail -1)
    # if [ -f /mnt/archgen/DAG_GL/samples/${basename}.bam ]; then
    #     libsIncluded=$(samtools view -H /mnt/archgen/DAG_GL/samples/${basename}.bam | grep ^@RG | sed 's/\t/\n/g' | sort | uniq | grep "^PU" | sed 's/PU\://g' | tr '\n$' '\,' | sed 's/\,$//g')
    # else
        libsIncluded=""
    # fi
    

    #check if the imputation pipeline picked the sample up
    impFilePres=$(ls /mnt/archgen/DAG_imputation/IMPOUT/${basename}/${basename}_imputed.vcf.gz 2>/dev/null | wc -l)
    impLastMod=$(date -r /mnt/archgen/DAG_imputation/IMPOUT/${basename}/${basename}_imputed.vcf.gz +%Y-%m-%d 2>/dev/null)
    impPublished=$(ls /mnt/archgen/Autorun_eager/eager_outputs/TF/${site}/${basename}/GTL_output/${basename}_imputed.vcf.gz 2>/dev/null | wc -l)
    impPubDate=$(date -r /mnt/archgen/Autorun_eager/eager_outputs/TF/${site}/${basename}/GTL_output/${basename}_imputed.vcf.gz +%Y-%m-%d 2>/dev/null)

    #check if it was included in the latest IBD release and in the master VCF
    inIBD=$(grep $basename $IBDdir/iid.ibd.meta.*.unique.tsv 2>/dev/null| wc -l)
    inMasterVCF=$(bcftools view -h /mnt/archgen/ibd_release/data_int/vcf.1240.master/${IBDversion}/ch21.vcf.gz | grep ${basename} | wc -l)
    frac_gp=$(cat $IBDdir/iid.ibd.meta.*.unique.tsv 2>/dev/null | grep $basename | cut -f 2)

    #check difference in coverage between GTL and Autorun
    covDifference=$(echo "scale=2; $coverageGTL - $higherCoverage" | bc)

    
    # #check if the creation date follows the expected order: Autorun BAM -> deduplication -> genotyping -> multiqc -> GTL -> imputation -> publication in GTL output
    # dates=("$dateAutorunProcessed" "$dateLastDedup" "$dateLastGeno" "$dateLastMultiqc" "$GTlastMod" "$impLastMod" "$impPubDate")
    # orderOK="YES"
    # prev=""
    # for d in "${dates[@]}"; do
    #     if [[ -n "$d" && -n "$prev" && "$prev" > "$d" ]]; then
    #         orderOK="NO"
    #         break
    #     fi
    #     if [[ -n "$d" ]]; then
    #         prev="$d"
    #     fi
    # done


    echo -e "${sample}\t${AutorunProcessed}\t${dateAutorunProcessed}\t${dateLastDedup}\t${dateLastMultiqc}\t${GTfilePres}\t${GTlastMod}\t${coverageGTL}\t${higherCoverage}\t${impFilePres}\t${impLastMod}\t${impPublished}\t${impPubDate}\t${inIBD}\t${inMasterVCF}\t${covDifference}" \
        | sed 's/\t1\t/\tYES\t/g'| sed 's/\t1\t/\tYES\t/g'| sed 's/\t1\t/\tYES\t/g' \
        | sed  's/\t0\t/\tNO\t/g' | sed  's/\t0\t/\tNO\t/g' | sed  's/\t0\t/\tNO\t/g' | sed  's/\t0\t/\tNO\t/g' >> $tag.tsv

done 

echo -e "\nReport generated: $tag.tsv"
