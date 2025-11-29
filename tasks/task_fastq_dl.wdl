version 1.0
# Uses fastq-dl to pull sra file(s) corresponding to the input sra number from the repository.
# Returns an array of files (1 for single end and 2 for paired end).

task fastq_dl_sra {
  input {
    String sra_accession
  }
  
  command <<<
    # write version to VERSION file for records
    fastq-dl --version | tee VERSION
    fastq-dl --accession ~{sra_accession}

    # tag single-end reads with _1
    if [ -f "~{sra_accession}.fastq.gz" ] && [ ! -f "~{sra_accession}_1.fastq.gz" ]; then
      mv "~{sra_accession}.fastq.gz" "~{sra_accession}_1.fastq.gz"
    fi
  >>>
  
  output {
    Array[File] reads = glob("~{sra_accession}_*.fastq.gz")
  }
  
  runtime {
    docker: "quay.io/biocontainers/fastq-dl:3.0.1--pyhdfd78af_0"
    memory:"8 GB"
    cpu: 2
    disks: "local-disk 100 SSD"
    preemptible:  1
  }
}
