#!/bin/bash



### Adjust the parameters below ###

project=/home/schae234/Codes/NascentTranscriptionWorkshop/data
rootname=SRR1105737.sampled
refdir=/var/tmp/reference

### Adjust the parameters above ###




pwd; hostname; date
date

###analyze read distributions using RSeQC -- will give you number of reads over different regions of genome dependent on the input annotation file (typically will be over genes, but you can imagine the applicability to eRNA calls eventually for quick comparison of relative eRNA coverage between samples)

### RSeQC has a number of different tools. For a full list with given examples, visit: http://rseqc.sourceforge.net/
### All of the tools included with RSeQC are included in this instance, and can be called by mytest.py similiar to that shown in this script

read_distribution.py  -i ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam \
 -r ${refdir}/GeneAnnotations/hg38_refseq.bed > ${project}/qc/rseqc/${rootname}.read_dist.txt

echo rseqc
date
date

