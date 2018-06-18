#!/bin/bash




### Adjust the parameters below ###

project=/home/schae234/Codes/NascentTranscriptionWorkshop/data
rootname=SRR1105737.sampled

### Adjust the parameters above ###





pwd;hostname;date
date

### FastQC (QC = Quality Control) -- good to check if you're unsure what experiment protocol was used, whether or not data coming off the sequencer is good, etc.

fastqc ${project}/trimmed/${rootname}.trim.fastq -o ${project}/trimmed/FastQC

