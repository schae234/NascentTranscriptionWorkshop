#!/bin/bash


### Adjust the parameters below ###

project=/home/schae234/Codes/NascentTranscriptionWorkshop/data
rootname=SRR1105737.chr1
refdir=/var/tmp/reference

### Adjust the parameters above ###



echo Running bidir_old module
date

Tfit bidir \
 -ij ${project}/mapped/bedgraph/${rootname}.tri.BedGraph \
 -N ${rootname}.bidir_old \
 -o ${project}/data/tfit \
 -log_out ${project}/tfit/${rootname}.log \
 -tss ${refdir}/GeneAnnotations/hg38_TSS_UCSC_refseq_1000bprange.bed

echo bidir_old module complete

echo Running Model module
date

mpirun -np 4 ${src} model \
 -ij ${bedPath}${rootname}.tri.BedGraph \
 -k $tfitOut/${rootname}.bidir_old-1_prelim_bidir_hits.bed \
 -N ${rootname}.tfit_mod_old9 \
 -log_out /scratch/Users/magr0763/Gerber/GRO-seq/Data_Analysis/tfit_test/logs/${rootname}.tsv \
 -o /scratch/Users/magr0763/Gerber/GRO-seq/Data_Analysis/tfit_test/model/\
 -config ${config}

echo model module complete
echo Job completed
date
date
