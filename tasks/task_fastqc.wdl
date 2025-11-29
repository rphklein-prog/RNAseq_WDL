version 1.0

task fastqc {
	input {
		File fastq
		Int addldisk = 10
		Int cpu = 4
		Int memory = 8
	}
	# dynamically calculate disk needs
	Int finalDiskSize = addldisk + ceil(size(fastq, "GB"))

	command <<<
		mkdir outputs
		fastqc -o outputs ~{fastq}
	>>>

    output {
      Array[File] html_report = glob("outputs/*_fastqc.html")
    }
    
	runtime {
		cpu: cpu
		docker: "biocontainers/fastqc:v0.11.9_cv8"
		disks: "local-disk " + finalDiskSize + " SSD"
		memory: memory + " GB"
		preemptible: 1
	}
}
