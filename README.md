RNA-seq WDL workflow formatted with modular tasks to allow workflow customization.

RNAseq_mod.wdl: combines functions into a single workflow: starts with a list of SRA accession numbers (can be a Terra data table with SRR ids in a column), a list matching each SRA accession 
number to a sample type (ex- Treatment or Control), and the desired salmon index for quantification. It pulls data from the SRA repository then trims adapters with bbduk (defaults are Illumina 
universal adapters), runs fastqc to check that adapters have been removed and sequence quality is acceptable, and quantifies reads with salmon. Assumes data are paired-end with F and R reads.

tasks:
task_fastq_dl.wdl: Uses fastq-dl to pull sra file(s) corresponding to the input sra accession number(s) from the repository. Returns an array of files (2 for paired end).

task_bbduk.wdl: takes input fastq files and runs bbduk to trim adapter sequences. Returns an array of files (forward and reverse reads). default trimming = illumina universal adapters, 
but could be changed in code as needed. See https://github.com/BioInfoTools/BBMap

task_fastqc.wdl: runs fastqc on input fastq files and provides stats on read quality. See https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

salmon_task.wdl: runs salmon read quantification on paired-end RNA-seq data. See https://salmon.readthedocs.io/en/latest/salmon.html

