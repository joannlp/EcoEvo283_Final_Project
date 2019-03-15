###Using platypus to call variants in a DNA sequencing dataset
#!/bin/bash
#$ -N platypus_test
#$ -q bio,abio,free*i
#$ -ckpt restart
#$ -t 1-
#$ -tc 4

module purge
module load joannlp/miniconda2
#this relies on python 2.7

cd /pub/joannlp/EcoEvo283/Bioinformatics_Course/
#ls A[4567]/DNA/*.sorted.bam > platypus_test_jobfile.txt
#Do this before running the script. This creates a list of files for the job

JOBFILE=platypus_test_jobfile.txt
SEED=$(head -n ${SGE_TASK_ID} ${JOBFILE} | tail -n 1)
workingdir=$(dirname ${SEED})
filename=$(basename ${SEED})
prefix=$(basename ${filename} .sorted.bam)
ref=/pub/joannlp/EcoEvo283/Bioinformatics_Course/ref/dmel-all-chromosome-r6.13.fasta

#my environment that has platypus-variant
source activate SNP_caller

#basic script for platypus. there are other specialized options
#/data/apps/user_contributed_software/joannlp/miniconda2/2/envs/SNP_caller/share/platypus-variant-0.8.1.2-0/
#Instead of running one bam file at a time, you could input a list of bam files separated by comma and will result in one vcf file

platypus callVariants --bamFiles=${workingdir}/${prefix}.sorted.bam --refFile=${ref} --output=${workingd
ir}/${prefix}.platypus.vcf --logFileName=platypus.log.txt --genSNPs=1 --genIndels=1 --minBaseQual=20 --m
axVariants=8