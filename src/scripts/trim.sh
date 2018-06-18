#!/bin/bash




### Adjust the parameters below ###

project=/home/schae234/Codes/NascentTranscriptionWorkshop/data
rootname=SRR1105737.sampled
refdir=/var/tmp/reference

### Adjust the parameters above ###



### In this workshop we will use bbduk (part of the BBMap suite) to trim. There are a number of trimming tools (Trimmomatic, TrimGalore, cutadapt) that you may also try that are installed on this instance.

# bbduk manual : https://github.com/BioInfoTools/BBMap/blob/master/sh/bbduk.sh ; https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbduk-guide/
# TrimGalore manual : https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/
# Trimmomatic manual : http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf
# cutadapt manual : http://cutadapt.readthedocs.io/en/stable/guide.html

### I prefer bbduk due to the large number of options that facilitate a wide array of trimming needs

### Trim fastq files for adapters, quality, etc.
# in = input .fastq file
# out = specifies output file/directory where you want you trimmed file to go
# ref = reference fa file that contains a list of adapters you wish to be screened/trimmed (similar to a fastq file only it does not contain quality information -- list of sequences only)
# ktrim = which side you want to trim adapters from (5',3', unspecified)
# qtrim = minimum quality of reads that will be kept
# k = kmer length used for finding contaminants -- kmers shorter than specified number will not be found; can also specify maskmiddle=t to treat middle base of kmer as a wildcard and increase sensitivity/trimming
# mink = if you specify k, then all kmers with x length will be binned and used as references. However, when you are trimming on reads with that matching length will be discarded and reads with a partial match will not be trimmed. By setting mink, you will look for reads between k=x and mink=y (x and y are integer lengths in bp) for matches to the binned k=x kmers
# hdist = hamming distance (bins reads within a kmer and allows a certain number of mismatches within that distance)
# maq = drops read with less than an average quality specified
# minlen = minimum length of reads that will be kept -- very protocol dependent, but important to specify with adapter trimming

pwd;hostname;date
date

bbduk.sh -Xmx1g \
overwrite=t \
in=${project}/fastq/${rootname}.fastq \
out=${project}/trimmed/${rootname}.trim.fastq \
ref=${refdir}/adapters.fa \
ktrim=r qtrim=10 k=23 mink=11 \
maq=10 minlen=20 \
stats=${project}/trimmed/${rootname}.trim.stats.txt \
#maxgc=1 \
#literal=CCCGTGTTGAGTCAAATTAAGCCGCAGGCTCCACTCCTGGTGGTGCCCTT \
# tpe tbo \

echo bbduk trim
date
date
