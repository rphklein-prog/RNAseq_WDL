version 1.0

# This workflow starts with SRA accession numbers. It pulls data from sra then trims adapters 
# with bbduk (defaults are Illumina universal adapters), runs fastqc to check that adapters 
# have been removed and sequence quality is acceptable, and finally, quantifies reads with salmon. 
# Assumes data is paired-end with F and R reads.

import "tasks/task_fastq_dl.wdl" as dl
import "tasks/task_bbduk.wdl" as trim
import "tasks/task_fastqc.wdl" as qc
import "tasks/salmon_task.wdl" as salmon_run

workflow fetch_sra_to_fastqc {
  input {
    String sra_accession
    Int addldisk = 10
	Int cpu = 4
	Int memory = 8
	String sample_id
	File salmon_index_tar 
  }
  
  call dl.fastq_dl_sra {
    input:
      sra_accession=sra_accession
  }

# use bbduk to trim adapters from reads (default are Illumina universal adapters)
  call trim.bbduk {
    input:
      fastq1 = fastq_dl_sra.reads[0],
      fastq2 = fastq_dl_sra.reads[1] 
  }
  
  # run fastqc on both forward and reverse reads by scattering
  scatter (fq in bbduk.trimmed_reads){
    call qc.fastqc {
   	  input:
        fastq = fq,
        addldisk = addldisk,
        cpu = cpu,
        memory = memory    
    }
  }
  
  call salmon_run.salmon_quant {
    input:
      fastq1 = bbduk.trimmed_reads[0],
      fastq2 = bbduk.trimmed_reads[1],
      salmon_index_tar = salmon_index_tar,
      sample_id = sample_id
  }
  
  output {
    Array[File] reads = fastq_dl_sra.reads
    Array[File] report = flatten(fastqc.html_report)
    Array[File] trimmed_reads = bbduk.trimmed_reads
    File quant_sf = salmon_quant.quant_sf
    Array[File] quant_results = salmon_quant.quant_results
  }
}
