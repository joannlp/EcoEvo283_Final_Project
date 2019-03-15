# EcoEvo283_Final_Project

The goal of my final project is to create a conda environment for calling variants on DNA sequencing data. The program I will be using is platypus-variant. 

In the first part of the course, we downloaded miniconda3 onto our HPC accounts. Miniconda3 relies on Python3. However, based on one of the platypus manuals online (https://rahmanteamdevelopment.github.io/Platypus/documentation.html), only python version 2.7 is supported. 

To avoid interferences between the newer version of miniconda and python and the older versions, I deleted miniconda3 and downloaded miniconda2 with a python 2.7 environment. 

First, Go into /data/modulefiles/user_contributed_software/joannlp
Create new folder: mkdir miniconda2
Make file within folder, name it 2: 

#%Module1.0

module-whatis "Joann's miniconda2 installation"

exec /bin/logger -p local6.notice -t module-hpc $env(USER) "joannlp/miniconda2/2"

set ROOT /data/apps/user_contributed_software/joannlp/miniconda2/2

prepend-path    PATH               $ROOT/bin

## for dev/lib installs
prepend-path -d " "   LDFLAGS           "-L${ROOT}/lib"
prepend-path -d " "   CPPFLAGS          "-I$ROOT/include"
prepend-path          INCLUDE           "$ROOT/include"

Second, Go into: /data/apps/user_contributed_software/joannlp
Make new directory miniconda2. Within that folder, 
Wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh

Once you have this downloaded, run the script: bash Miniconda2-latest-Linux-x86_64.sh 
and place in folder: /data/apps/user_contributed_software/joannlp/miniconda2/2

If I put it in the miniconda2 folder, it did not let me and printed an error so I put it in 2, which did not exist yet


To call, module load joannlp/miniconda2

To look at your list of environments, conda env list

To make a new environment, conda create –n SNP_caller python=2.7

# To activate this environment, use:
# > source activate SNP_caller
#
# To deactivate an active environment, use:
# > source deactivate

The platypus-variant works
# https://anaconda.org/bioconda/platypus-variant
conda install -c bioconda platypus-variant

Platypus also requires virtualenv
https://rahmanteamdevelopment.github.io/Platypus/documentation.html
pip install virtualenv

To check to see if it is downloaded to my environment, conda list –n SNP_caller

To search for packages to install, conda search program name (for example bwa)
A list will appear that will have the name, version, build, and channel 




To run platypus on a small dataset, I have a smaller file to test on:
ADL06.sorted.sub.bam

Call to run platypus
platypus callVariants --bamFiles=ADL06.sorted.sub.bam --refFile=/pub/joannlp/EcoEvo283/Bioinformatics_Course/ref/dmel-all-chromosome-r6.13.fasta --output=ADL06.sorted.sub.bam.variant_calls.vcf

Output files: ADL06.sorted.sub.bam.variant_calls.vcf
Also a log.txt file that gives status of run:
2019-03-13 17:37:56,102 - INFO - Beginning variant calling
2019-03-13 17:37:56,103 - INFO - Output will go to ADL06.sorted.sub.bam.variant_calls.vcf
2019-03-13 17:37:56,334 - DEBUG - Loaded regions from BAM header, SQ tags
2019-03-13 17:37:56,334 - DEBUG - 1870 regions will be searched
2019-03-13 17:37:56,382 - DEBUG - Error in BAM header sample parsing. Error was 
'RG'

2019-03-13 17:37:56,382 - DEBUG - Adding sample name ADL06.sorted.sub, from BAM file ADL06.sorted.sub.bam
2019-03-13 17:37:56,388 - DEBUG - Max haplotypes used for initial haplotype filtering = 50
2019-03-13 17:37:56,388 - DEBUG - Max haplotypes used for genotype generation = 50
2019-03-13 17:37:56,388 - DEBUG - Max genotypes = 1275
2019-03-13 17:37:56,679 - INFO - Processing region 4:0-100000. (Only printing this message every 10 regions of size 100000)
2019-03-13 17:37:56,742 - DEBUG - There is one sample in each BAM file. No merging is required
2019-03-13 17:37:56,745 - DEBUG - There are 0 filtered variant candidates in reads which overlap the region 4:0-100000
2019-03-13 17:37:56,745 - DEBUG - There is one sample in each BAM file. No merging is required
2019-03-13 17:37:56,746 - DEBUG - There are 0 filtered variant candidates in reads which overlap the region 4:100000-200000
2019-03-13 17:37:56,747 - DEBUG - There is one sample in each BAM file. No merging is required
2019-03-13 17:37:56,748 - DEBUG - There are 0 filtered variant candidates in reads which overlap the region 4:200000-300000

etc…



Now, to install other packages that are used to run the snp calling pipeline. 
Packages we have used include:
bwa/0.7.8
conda install bwa=0.7.8

samtools/1.3
conda install samtools=1.3

bcftools/1.3
conda install bcftools=1.3

bowtie2/2.2.7
conda install bowtie2=2.2.7

Write a shell script to run platypus:
###test run for my conda environment for calling variants with platypus

#!/bin/bash
#$ -N platypus_test
#$ -q bio,abio,free*i
#$ -ckpt restart
#$ -t 1
#$ -tc 1

module unload
module load joannlp/miniconda2
#this relies on python 2.7

#ls A[4567]/DNA/*.sorted.bam > platypus_test_jobfile.txt

JOBFILE=platypus_test_jobfile.txt
SEED=$(head -n ${SGE_TASK_ID} ${JOBFILE} | tail -n 1)
workingdir=$(dirname ${SEED}
filename=$(basename ${SEED})
prefix=$(basename ${filename} .sorted.bam)
ref=/pub/joannlp/EcoEvo283/Bioinformatics_Course/ref/dmel-all-chromosome-r6.13.fasta

source activate SNP_caller

#basic script for platypus. there are other specialized options
platypus callVariants --bamFiles=${workingdor}/${prefix}.sorted.bam --refFile=${ref} --output=${workingdir}/${prefix}.platypus.vcf --logFileName=platypus.log.txt --genSNPs=1 --genIndels=1 --minBaseQual=20 --maxVariants=8

The output file is: ADL06_1.platypus.vcf

To host it online to upload onto the UCSC genome browser, you first have to make it readable or accessible to the internet. Note, the file path also has to be accessible. In order to do that, (instructions here: https://hpc.oit.uci.edu/sharing-data) 

chmod a+r ADL06_1.platypus.vcf

Next, link your file to this directory and it will be hosted at the website below.  

cd /pub/public-www/joannlp
ln -s /pub/joannlp/EcoEvo283/Bioinformatics_Course/A4/DNA/ADL06_1.platypus.vcf ADL06_1.platypus.vcf

To access the file, 
http://hpc.oit.uci.edu/~joannlp/ADL06_1.platypus.vcf

Go to the UCSC genome browser for D. melanogaster, add custom tracks, insert the link.

My test run was just on one sample, however you can input a list of bam files that will output one vcf file. 
