#!/bin/bash



### Adjust the parameters below ###

project=/home/schae234/Codes/NascentTranscriptionWorkshop/data
rootname=SRR1105737.sampled
refdir=/var/tmp/reference

### Adjust the parameters above ###



### There are a number of different mapping programs and aligners such as Bowtie2, STAR, BBMap (we will use some of the BBMap suite tools), howver here we will use Bowetie2

### Go to this link for a full list of Bowtie2 options: http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml
### Go to this link for the BBMap list of options: https://github.com/BioInfoTools/BBMap/blob/master/sh/bbmap.sh

# --phred33 = input qualities based on Illumia pipeline encoding
# -U = input file for unpaired reads
# -x reference genome files
# > specifies where output file will go
# 2> specifies where stderr file will go with mapping stats

pwd;hostname;date
date

bowtie2 --phred33  --very-sensitive \
 -x ${refdir}/Bowtie2Index/genome \
 -U ${project}/trimmed/${rootname}.trim.fastq > ${project}/mapped/sams/${rootname}.trimmed.sam 2> ${project}/mapped/sams/${rootname}.trimmed.stderr

echo mapped, sam
date
date

### The following steps will take your mapped sam file and produce compressed versions which are useful for further analysis, visuzalization, and storage. Additionally, we will read count correct (adjust for total read depth following mapping), produce stats files from mapping, and produce an index file which is needed for a variety of QC modules as well as if you decide to dissect your file by certain genomic features (e.g. by chromosome 1). This pipeline will produce just about everything you could need for post-data-processing analysis.

#Word count sam files, convert sam files to bam files (compressed, binary sam files)

wc -l ${project}/mapped/sams/${rootname}.trimmed.sam > ${project}/mapped/sams/${rootname}.trimmed.sam.wc
samtools view -S -b -o ${project}/mapped/bams/${rootname}.trimmed.bam ${project}/mapped/sams/${rootname}.trimmed.sam 2> ${project}/mapped/bams/${rootname}.trimmed.bam.err
samtools flagstat ${project}/mapped/bams/${rootname}.trimmed.bam > ${project}/mapped/bams/${rootname}.trimmed.bam.flagstat 2> ${project}/mapped/bams/${rootname}.trimmed.bam.flagstat.err
echo bam
date
date

#Sort bam files, flagstat useful for rcc (read count correction) and QC

samtools sort -m 16G ${project}/mapped/bams/${rootname}.trimmed.bam > ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam
samtools flagstat ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam > ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam.flagstat 2> ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam.flagstat.err
echo sorted.bam
date
date

#Index sorted bam files for use in mutlicov OR if you decide to sort out a specific region (e.g. use samtools view to select only chromosome 1)

samtools index ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam.bai

echo bam, indexed, sorted
date
date

#Read count correcting (rcc) -- reducing sequencing bias based on depth for visualization in IGV

python ${refdir}/readcountcorrectBG.py ${project}/mapped/bedgraph/${rootname}.tri.BedGraph ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam.flagstat ${project}/mapped/bedgraph/${rootname}.tri.rcc.BedGraph
echo readcountcorrectedbedgraph
date
date

#Generate tdfs (compressed bedgraphs) -- mapped reads easily viewable in IGV

igvtools toTDF ${project}/mapped/bedgraph/${rootname}.tri.rcc.BedGraph ${project}/mapped/tdfs/${rootname}.tri.tdf ${refdir}/hg38.chrom.sizes
echo tdf
date
date
