# EcoEvo283_Final_Project

The goal of my final project is to create a conda environment for calling variants on DNA sequencing data. The program I will be using is platypus-variant. In the first part of the course, we downloaded miniconda3 onto our HPC accounts. Miniconda3 relies on Python3. However, based on one of the platypus manuals online (https://rahmanteamdevelopment.github.io/Platypus/documentation.html), only python version 2.7 is currently supported. To avoid interferences between the newer version of miniconda and python and the older versions, I deleted miniconda3 and downloaded miniconda2 with a python 2.7 environment. 

## Here is a list of jobs I needed to accomplish:
* 1. Download the correct miniconda based on the correct python for running platypus-variant (miniconda2)
* 2. Create a conda environment
* 3. Download platypus-variant into my environment
* 4. Test run platypus on a subset of data in the command line
* 5. Write a script to run platypus on a larger set of data
* 6. Host my vcf file onto the HPC website
* 7. Upload the hosted vcf file onto UCSC Genome Browser

## Here are the steps I took to accomplish these tasks:
### 1. Download the correct miniconda based on the correct python for running platypus-variant (miniconda2)
a. First, Go into /data/modulefiles/user_contributed_software/joannlp. Create new folder: mkdir miniconda2. Make file within folder, name it 2: 
```
#%Module1.0

module-whatis "Joann's miniconda2 installation"

exec /bin/logger -p local6.notice -t module-hpc $env(USER) "joannlp/miniconda2/2"

set ROOT /data/apps/user_contributed_software/joannlp/miniconda2/2

prepend-path    PATH               $ROOT/bin

## for dev/lib installs
prepend-path -d " "   LDFLAGS           "-L${ROOT}/lib"
prepend-path -d " "   CPPFLAGS          "-I$ROOT/include"
prepend-path          INCLUDE           "$ROOT/include"
```
b. Go into ```/data/apps/user_contributed_software/joannlp``` Make new directory miniconda2. Within that folder, 
```Wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh```

c. Once you have this downloaded, run the script: bash Miniconda2-latest-Linux-x86_64.sh 
and place in folder: /data/apps/user_contributed_software/joannlp/miniconda2/2
If I put it in the miniconda2 folder, it did not let me and printed an error so I put it in 2, which did not exist yet


d. To call, ```module load joannlp/miniconda2```


### 2. Create a conda environment
a. To look at your list of environments, ```conda env list``` 
To make a new environment, ```conda create –n SNP_caller python=2.7```
To activate this environment, use: ```source activate SNP_caller```
To deactivate an active environment, use: ```source deactivate```

### 3. Download platypus-variant into my environment
The platypus-variant works (https://anaconda.org/bioconda/platypus-variant)
The other platypus that can be downloaded, however does not work for some reason. They look like the same package and have the same options, but platypus does not work, while platypus-variant does wor. 

a. ```conda install -c bioconda platypus-variant```

b. Platypus also requires virtualenv
https://rahmanteamdevelopment.github.io/Platypus/documentation.html
```pip install virtualenv```

To check to see if it is downloaded to my environment, ```conda list –n SNP_caller```

To search for packages to install, ```conda search program_name``` (for example bwa)
A list will appear that will have the name, version, build, and channel 

### 4. Test run platypus on a subset of data in the command line
a. To run platypus on a small dataset, I have a smaller file to test on:
ADL06.sorted.sub.bam

b. Call to run platypus
```platypus callVariants --bamFiles=ADL06.sorted.sub.bam --refFile=/pub/joannlp/EcoEvo283/Bioinformatics_Course/ref/dmel-all-chromosome-r6.13.fasta --output=ADL06.sorted.sub.bam.variant_calls.vcf```

Output files: ADL06.sorted.sub.bam.variant_calls.vcf

c. Now, to install other packages that are used to run the snp calling pipeline. 
Packages we have used include:

bwa/0.7.8 ```conda install bwa=0.7.8```

samtools/1.3 ```conda install samtools=1.3```

bcftools/1.3 ```conda install bcftools=1.3```

bowtie2/2.2.7 ```conda install bowtie2=2.2.7```

### 5. Write a script to run platypus on a larger set of data
Write a shell script to run platypus:
###test run for my conda environment for calling variants with platypus
```
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
```
The output file is: ADL06_1.platypus.vcf

### 6. Host my vcf file onto the HPC website
a. To host it online to upload onto the UCSC genome browser, you first have to make it readable or accessible to the internet. Note, the file path also has to be accessible. In order to do that, (instructions here: https://hpc.oit.uci.edu/sharing-data) 

```chmod a+r ADL06_1.platypus.vcf```

b. Next, link your file to this directory and it will be hosted at the website below.  

```
cd /pub/public-www/joannlp
ln -s /pub/joannlp/EcoEvo283/Bioinformatics_Course/A4/DNA/ADL06_1.platypus.vcf ADL06_1.platypus.vcf
```
To access the file, 
http://hpc.oit.uci.edu/~joannlp/ADL06_1.platypus.vcf

### 7. Upload the hosted vcf file onto UCSC Genome Browser
Go to the UCSC genome browser for D. melanogaster, add custom tracks, insert the link.

My test run was just on one sample, however you can input a list of bam files that will output one vcf file. 
