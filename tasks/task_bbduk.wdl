version 1.0

# takes input (fastq) files and trims adapter sequences. returns an array of f and r
# trimmed sequences. default trimming is for illumina universal adapters, but could be
# changed as needed.

task bbduk {
  input {
    File fastq1
    File fastq2
    String adapter_F = "AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT"
    String adapter_R = "GATCGGAAGAGCACACGTCTGAACTCCAGTCACGGATGACTATCTCGTATGCCGTCTTCTGCTTG"
  }
  
  # dynamically calculate disk needs
  Int disk_size = ceil((size(fastq1, "GB") + (if defined(fastq2) then size(fastq2, "GB") else 0)) * 3)
  
  # strip the name from the fastq1 file to use for outputs
  String prefix = sub(basename(fastq1), "\\.f(ast)?q(\\.gz)?$", "")
  
  
  command <<<
    set -euxo pipefail
    # Run bbduk
    bbduk.sh \
      in1=~{fastq1} \
      in2=~{fastq2} \
      out1=~{prefix}_trimmed_1.fastq.gz \
      out2=~{prefix}_trimmed_2.fastq.gz \
      literal=~{adapter_F},~{adapter_R} \
      ktrim=r \
      k=23 \
      mink=11 \
      hdist=1 \
      tpe \
      tbo
  >>>

  output {
    # Match files for both forward and reverse reads if present
    Array[File] trimmed_reads = glob("~{prefix}_trimmed_*.fastq.gz")
  }

  runtime {
    docker: "quay.io/biocontainers/bbmap:38.96--h5c4e2a8_0"
    memory: "8 GB"
    cpu: 2
    disks: "local-disk " + disk_size + " SSD"
  }
}

