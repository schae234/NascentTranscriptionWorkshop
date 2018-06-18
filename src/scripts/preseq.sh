#!/bin/bash




### Adjust the parameters below ###

project=/home/schae234/Codes/NascentTranscriptionWorkshop/data
rootname=SRR1105737.sampled
refdir=/var/tmp/reference

### Adjust the parameters above ###




pwd; hostname; date
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
