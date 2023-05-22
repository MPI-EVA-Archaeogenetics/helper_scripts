#!/usr/bin/env bash

input=$1

while read line; do
	iid=($(echo ${line} | awk '{print $1}'))
	num=($(grep -n ${iid} /mnt/archgen/Autorun_eager/*_Autorun_eager_queue.txt | cut -f 1 -d " " | sed s/":cd"/""/g | rev | cut -f 1 -d ":" | rev | tail -1))
	run=($(grep -n ${iid} /mnt/archgen/Autorun_eager/*_Autorun_eager_queue.txt | cut -f 1 -d " " | sed s/":cd"/""/g | rev | cut -f 2- -d ":" | cut -f 1 -d "/" | rev | tail -1))
	status=($(exec 2>&- grep "Pipeline completed" /mnt/archgen/Autorun_eager/array_Logs/${run}/AE_spawner*txt.o*.${num} | awk '{OFS = "-"; print $2,$3,$4}'))
	echo -e ${iid}"\t"${status} >> ${input}_samples_eager_status.txt
done < <(cat ${input})

