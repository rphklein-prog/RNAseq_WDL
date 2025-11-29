version 1.0

# runs salmon quant on fastq files. assumes paired end sequencing with f and r reads.
# returns an array of output files as well as the quant_sf file individually, which can
# be used as input for differential expression analysis.

task salmon_quant {
  input {
    File fastq1
    File fastq2
    String sample_id
    File salmon_index_tar
  }

# run salmon	
  command <<<
    set -euo pipefail
    # extract salmon index and put into a folder
    tar -xzvf ~{salmon_index_tar}
    INDEX_DIR=$(tar -tzf ~{salmon_index_tar} | head -1 | cut -f1 -d"/" || echo ".")
    salmon quant \
      -i "${INDEX_DIR}" \
      -l A \
      -1 ~{fastq1} \
      -2 ~{fastq2} \
      -p 4 \
      -o "~{sample_id}_quant" \
      --seqBias \
      --useVBOpt \
      --validateMappings 
  >>>
		
  output {
    File quant_sf = "~{sample_id}_quant/quant.sf"
    Array[File] quant_results = glob("~{sample_id}_quant/*")
  }

# default runtime set-up, modify as needed		
  runtime {
    docker: "quay.io/biocontainers/salmon:1.10.3--h45fbf2d_5"
    cpu: 4
    memory: "32G"
    disks: "local-disk 250 SSD"
    preemptible: 1
  }
}
