# Autorun_multiqc_stats_collect

This is a script for collecting a batch of one-library-individuals' multiqc stats for capture data. It should also work for shotgun but need to make adaptations since the columns are not the same.

Put all the sample ID (e.g. AGV001) into one text, one ID per line. Then run the script. Pay attention to in which folder your data is saved. (/mnt/archgen/Autorun_eager/eager_outputs/TF/’site’/’individual’/multiqc/multiqc_data/multiqc_general_stats.txt
/mnt/archgen/Autorun_eager/eager_outputs_old/TF/ ’site’/’individual’/multiqc/multiqc_data/multiqc_general_stats.txt)

The original titles of the data are kept but always check if the columns are aligned correctly since the multiqc parameters might change. Especially when your sample has more than 1 library, the sequence of the data is not the same.
