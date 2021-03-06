#!/bin/bash




### Adjust the parameters below ###

project=/home/schae234/Codes/NascentTranscriptionWorkshop/data
rootname=SRR1105736.chr1
refdir=/var/tmp/reference

### Adjust the parameters above ###



pwd;hostname;date
date

### Pre-trim FastQC (QC = Quality Control) -- good to check if you're unsure what experiment protocol was used, whether or not data coming off the sequencer is good, etc

fastqc ${project}/fastq/${rootname}.fastq -o ${project}/fastq

echo fastqc pre-trim
date
date

#This will flip your reads (reverse complement) -- your need to do this depends on protocol. The protocol used in this sample experiment will require flipping

echo flipping
date
date

fastx_reverse_complement -Q33 -i ${project}/fastq/${rootname}.fastq -o ${project}/fastq/${rootname}.flip.fastq

echo done flipping
date
date

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

bbduk.sh -Xmx1g \
overwrite=t \
in=${project}/fastq/${rootname}.flip.fastq \
out=${project}/trimmed/${rootname}.trim.fastq \
ref=${project}/reference/adapters.fa \
ktrim=r qtrim=10 k=23 mink=11 hdist=1 \
maq=10 minlen=20 \
stats=${project}/trimmed/${rootname}.trim.stats.txt \
#maxgc=1 \
#literal=CCCGTGTTGAGTCAAATTAAGCCGCAGGCTCCACTCCTGGTGGTGCCCTT \
# tpe tbo \

echo bbduk trim
date
date


### Perform FastQC again to determine whether your trim parameters were set properly and sufficient to move foward to mapping and minimizing read loss

fastqc ${project}/trimmed/${rootname}.trim.fastq -o ${project}/trimmed/FastQC

echo fastqc post-trim complete
date
date

### There are a number of different mapping programs and aligners such as Bowtie2, STAR, BBMap (we will use some of the BBMap suite tools), however here we will use Bowetie2

### Go to this link for a full list of Bowtie2 options: http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml
### Go to this link for the BBMap list of options: https://github.com/BioInfoTools/BBMap/blob/master/sh/bbmap.sh

# --phred33 = input qualities based on Illumia pipeline encoding
# -U = input file for unpaired reads
# -x reference genome files
# > specifies where output file will go
# 2> specifies where stderr file will go with mapping stats

echo begin mapping
date
date

bowtie2 --phred33  --very-sensitive \
 -x ${refdir}/Bowtie2Index/genome \
 -U ${project}/trimmed/${rootname}.trim.fastq > ${project}/mapped/sams/${rootname}.trimmed.sam 2> ${project}/mapped/sams/${rootname}.trimmed.stderr

echo mapped, sam
date
date

### The following steps will take your mapped sam file and produce compressed versions which are useful for further analysis, visuzalization, and storage. Additionally, we will read count correct (adjust for total read depth following mapping), produce stats files from mapping, and produce an index file which is needed for a variety of QC modules as well as if you decide to dissect your file by certain genomic features (e.g. by chromosome 1). This pipeline will produce just about everything you could need for post-data-processing analysis.

### We will use three primary tool packages : samtools, bedtools, and igvtools

# samtools manual : http://www.htslib.org/doc/samtools.html ; http://samtools.sourceforge.net/
# bedtools manual : http://bedtools.readthedocs.io/en/latest/index.html
# igvtools manual : https://software.broadinstitute.org/software/igv/igvtools

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

### Preseq is a useful tool that you can use to estimately library complexity. The reference line that you get if you run the output through MultiQC has a slope of 1 (which means every read is unique). While nascent samples will notever have a slope of 1 (unless you were to remove all duplicates which is not typically encouraged), they will instead have a parabolic shape (e.g. at some point you will approach a limit which represents the number of possible unique reads in your sample and a likelihood that you will continue to get unique reads if you were to continue sequencing at higher depths.

### There is also an R package available for preseq. The userguide and R package can both be accessed through the lab's github page for preseq : https://github.com/smithlabcode/preseq

### Both of the tools below are expected to be used on reads with sufficiently high read depth ( >20M reads). There is, however, another option in preseq that will adjust the aglorithm to predict future read depth for low read depth runs ( <20M reads). This is useful if you want to pre-screen your library for complexity to determine an appropriate read depth for your experiemental goals, as well as getting an assessment for max optimal read depth.

#c_curve : can use inputs from file types [bed/bam] and will plot the estimated complexity of a sample. Specify -B for sorted bam files, -P for paired end read files

preseq c_curve -B \
 -o ${project}/qc/preseq/${rootname}.c_curve.txt \
 ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam

echo c_curve
echo complexity
date

#lc_extrap : can use inputs from from tyles [bed/bam] and will estimate future yields for complexity if the sample is sequenced at higher read depths. Specify -B for sorted bam files, -P for paired end reads

preseq lc_extrap -B \
 -o ${project}/qc/preseq/${rootname}.lc_extrap.txt \
 ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam

echo lc_extrap
echo future yield
date

### Analyze read distributions using RSeQC (e.g. percent coverage over exons, introns, intergenic, etc.) -- will give you number of reads over different regions of genome dependent on the input annotation file (typically will be over genes, but you can imagine the applicability to eRNA calls eventually for quick comparison of relative eRNA coverage between samples)

### RSeQC has a number of different tools. For a full list with given examples, visit: http://rseqc.sourceforge.net/
### All of the tools included with RSeQC are included in this instance, and can be called by mytest.py similiar to that shown in this script

read_distribution.py  -i ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam \
 -r ${refdir}/GeneAnnotations/hg38_refseq.bed > ${project}/qc/rseqc/${rootname}.read_dist.txt

echo rseqc
date
date

#BedGraph generator -- generating positive and negative strand mapping; awk coverts values to negative values for negative strand mapping

#NOTE: For the current input of FStitch, it is VERY important to include "pos" somewhere in your output BedGraph file name, otherwise you will run into problems with your training data

bedtools genomecov -bg -strand + -ibam ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam > ${project}/mapped/bedgraph/${rootname}.tri.pos.BedGraph
bedtools genomecov -bg -strand - -ibam ${project}/mapped/bams/sorted/${rootname}.trimmed.sorted.bam | awk -F '	' -v OFS='	' '{ $4 = - $4 ; print $0 }' > ${project}/mapped/bedgraph/${rootname}.tri.neg.BedGraph
cat ${project}/mapped/bedgraph/${rootname}.tri.pos.BedGraph ${project}/mapped/bedgraph/${rootname}.tri.neg.BedGraph > ${project}/mapped/bedgraph/${rootname}.tri.unsorted.BedGraph
bedtools sort -i ${project}/mapped/bedgraph/${rootname}.tri.unsorted.BedGraph > ${project}/mapped/bedgraph/${rootname}.tri.BedGraph

echo BedGraph.pos.neg
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
