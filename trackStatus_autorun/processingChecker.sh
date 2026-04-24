#!bin/bash

v="1.0.0"

#get options
sampleList=$1
tag=$2
autoResultsDirs=/mnt/archgen/Autorun/Results
autoEagerDir=/mnt/archgen/Autorun_eager/eager_outputs
IBDdir=/mnt/archgen/ibd_release/v13.0
IBDversion=13.0

#if $1 is -v or --version, print version and exit
if [ "$sampleList" == "-v" ] || [ "$sampleList" == "--version" ]; then
    echo "processingChecker.sh version ${v}"
    exit 0
fi

#if $1 is "meow" print a cat and exit
if [ "$sampleList" == "meow" ]; then
echo "    /\_____/\ "
echo "   /  o   o  \ "
echo "  ( ==  ^  == ) "
echo "   )         ( "
echo "  (           ) "
echo " ( (  )   (  ) ) "
echo "(__(__)___(__)__) "
exit 0
fi

#print help if sampleList is -h or $1 or $2 is empty
if [ "$sampleList" == "-h" ] || [ -z "$sampleList" ] || [ -z "$tag" ]; then
    echo "Usage: $0 <sample_list.txt> <output_tag>"
    echo "Example: $0 samples_to_check.txt report_$(date +%Y%m%d)"
    exit 1
fi



cat /mnt/archgen/Autorun/Pandora_Tables/{Human_RM.txt,Human_RP.txt,Human_Shotgun.txt,Human_TM.txt,Human_1240k.txt} \
        | cut -f1 \
        | sort \
        | uniq \
        > /mnt/archgen/DAG_GL/list_seqs.txt


#make header
echo -e "Sample\tAutorun_Processed\tAutorun_date\tDeduplication_date\tDateLastMultiqc\tATLAS\tATLAS_lastMod\tCoverage_inATLAS\tCoverage_Autorun\tImputed\tImputation_date\tGTL_output_published\tGTL_output_date\tIBD_v${IBDversion}\tInMasterVCF_v${IBDversion}\tcovATLAS-covAutorun" > $tag.tsv

#Run throgh the scripts
progress=0
total=$(grep -f $sampleList /mnt/archgen/DAG_GL/list_seqs.txt| wc -l)

for sample in $(cat /mnt/archgen/DAG_GL/list_seqs.txt | grep -f $sampleList); do
    progress=$((progress + 1))
    printf "\rProcessing sample %s (%d/%d)" "$sample" "$progress" "$total"

    basename=$(echo $sample | cut -f 1 -d ".")
    TLC=${basename:0:-3}
    library=$(echo $sample | cut -f 2 -d ".")
    cap=$(echo $sample | cut -f 3 -d ".")
    captype=$(echo $sample | cut -f 3 -d "." | cut -c 1,2)
    seq=$(echo $sample | cut -f 4 -d ".")

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
    mostRecDedup=$(ls ${autoEagerDir}/${captype}/${TLC}/${basename}/deduplication/${basename}*/${basename}*rmdup.bam  2>/dev/null | tail -1)
    dateLastDedup=$(date -r $mostRecDedup +%Y-%m-%d)
    mostRecGeno=$(ls ${autoEagerDir}/${captype}/${TLC}/${basename}/genotyping/pileupcaller*.geno \
                        -tr 2>/dev/null | tail -1)
    dateLastGeno=$(date -r $mostRecGeno +%Y-%m-%d 2>/dev/null)
    mostRecGenoPresent=$(ls ${autoEagerDir}/${captype}/${TLC}/${basename}/genotyping/pileupcaller*.geno 2>/dev/null | wc -l)
    coverageAutorun=$(cat ${autoEagerDir}/${captype}/${TLC}/${basename}/genotyping/*_coverage.txt 2>/dev/null \
                    | awk '{print $2}' | grep -v "SNPs_Covered" \
                    | tr "\n" "\," | sed 's/\,$//g')
    higherCoverage=$(echo $coverageAutorun | tr "," "\n" | sort -n | tail -1)
    multiqcPresent=$(ls ${autoEagerDir}/${captype}/${TLC}/${basename}/multiqc/multiqc_report.html 2>/dev/null | wc -l)
    dateLastMultiqc=$(date -r ${autoEagerDir}/${captype}/${TLC}/${basename}/multiqc/multiqc_report.html +%Y-%m-%d 2>/dev/null)

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
    impPublished=$(ls /mnt/archgen/Autorun_eager/eager_outputs/TF/${TLC}/${basename}/GTL_output/${basename}_imputed.vcf.gz 2>/dev/null | wc -l)
    impPubDate=$(date -r /mnt/archgen/Autorun_eager/eager_outputs/TF/${TLC}/${basename}/GTL_output/${basename}_imputed.vcf.gz +%Y-%m-%d 2>/dev/null)

    #check if it was included in the latest IBD release and in the master VCF
    inIBD=$(grep $basename $IBDdir/iid.ibd.meta.*.unique.tsv 2>/dev/null| wc -l)
    inMasterVCF=$(bcftools view -h /mnt/archgen/ibd_release/data_int/vcf.1240.master/v${IBDversion}/ch21.vcf.gz | grep ${basename} | wc -l)
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