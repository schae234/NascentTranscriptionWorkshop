#!/bin/bash



### Adjust the parameters below ###

project=/home/schae234/Codes/NascentTranscriptionWorkshop/data
rootname=SRR1105736.chr1

### Adjust the parameters above ###




pwd;hostname;date
date

### FastQC (QC = Quality Control) -- good to check if you're unsure what experiment protocol was used, whether or not data coming off the sequencer is good, etc.

fastqc ${project}/fastq/${rootname}.fastq -o ${project}/fastq/FastQC


#This will flip your reads (reverse complement) -- your need to do this depends on protocol. The protocol used in this sample experiment will require flipping

echo flipping
date
date

fastx_reverse_complement -Q33 -i ${project}/fastq/${rootname}.fastq -o ${project}/fastq/${rootname}.flip.fastq

echo done flipping
date
date
