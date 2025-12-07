README.txt
===========

Project: Project_ibbc_<YourName>
---------------------------------

This repository contains a small NGS workflow for quality control, trimming, organelle assembly, and multi-sample reporting using FastQC, fastp, GetOrganelle, and MultiQC.

It is interactive, so you can select files or process all samples at once.

---------------------------------
Dependencies and Installation
---------------------------------

This workflow relies on several bioinformatics tools. The recommended way to install and manage them is through Conda and the Bioconda channel.

1. Install Conda (if not already installed)
   - Install Miniconda: https://docs.conda.io/en/latest/miniconda.html
   - Initialize your shell:
     conda init
   - Close and reopen your terminal after initialization.

2. Set up Conda channels:
   conda config --add channels defaults
   conda config --add channels bioconda
   conda config --add channels conda-forge

3. Create dedicated Conda environments for the tools:
   # QC tools environment
   conda create -n tools_qc fastqc fastp multiqc

   # Organelle assembly environment
   conda create -n organelles getorganelle

4. Activate the environment before running scripts:
   conda activate tools_qc
   # or
   conda activate organelles




---------------------------------
Scripts Overview
---------------------------------

1. script1.sh
   - Currently optional or placeholder
   - Can be used for project initialization or test data creation (customize if needed)
---------------------------------
Project Structure
---------------------------------
```
Project_ibbc_<YourName>/
|
├── 1_raw_data/          # Raw FASTQ files (.fastq.gz)
├── 2_metadata/          # Metadata (e.g., samples.txt)
├── 3_trimmed_data/      # Output from fastp trimming
├── 4_alignment/         # (Optional: future alignment results)
├── 5_results/           # Pipeline results
│   ├── fastqc/          # FastQC reports per sample
│   ├── fastp/           # fastp HTML and JSON reports
│   ├── getorganelle/    # GetOrganelle assemblies
│   └── multiqc/         # MultiQC aggregated reports
├── logs/                # Log files for each script
└── scripts/             # Scripts: script1.sh, script2.sh, script3.sh 
```
2. script2.sh – Main Interactive Pipeline
   Usage:
     bash script2.sh <ProjectName> <mode>
   Arguments:
     <ProjectName> : Name of the project (e.g., TiagoCosta)
     <mode>        : fastqc | fastp | organelle

   Modes:
   - fastqc: Runs FastQC on all FASTQ files in 1_raw_data/. Reports saved in 5_results/fastqc/. Logs in logs/fastqc.log
   - fastp: Performs trimming and adapter removal. Input from 1_raw_data/, output in 3_trimmed_data/ and 5_results/fastp/. Interactive file selection or 'all'.
   - organelle: Runs GetOrganelle on trimmed FASTQ files in 3_trimmed_data/. Output per sample in 5_results/getorganelle/. Requires trimmed FASTQ. Logs in logs/organelle.log. Use --overwrite if output folder exists.

3. script3.sh – MultiQC Aggregation
   Usage:
     bash script3.sh <ProjectName>
   - Detects FastQC and fastp reports
   - Generates a single MultiQC HTML report
   - Output folder: 5_results/multiqc/multiqc_report.html

---------------------------------
Example Workflow
---------------------------------

1. Place all raw FASTQ files in 1_raw_data/
2. Prepare metadata in 2_metadata/ if needed
3. Run FastQC on raw data:
     conda activate tools_qc
     bash script2.sh TiagoCosta fastqc
4. Run fastp trimming:
     bash script2.sh TiagoCosta fastp
5. Run organelle assembly:
     conda activate organelles
     bash script2.sh TiagoCosta organelle
6. Run MultiQC aggregation:
     conda activate tools_qc
     bash script3.sh TiagoCosta

---------------------------------
Tips and Notes
---------------------------------
- Check logs (logs/<mode>.log) for errors or warnings.
- FastQC, fastp, and GetOrganelle outputs can be large; monitor disk usage.
- GetOrganelle output directories should not be overwritten unless intended. Use --overwrite or --continue as needed.
- MultiQC automatically finds reports in 5_results/fastqc and 5_results/fastp.
- Scripts are interactive; you can select specific files or run all.
- Designed primarily for single-end Illumina FASTQ. Modify fastp or GetOrganelle parameters for paired-end reads if necessary.

---------------------------------
Contact / Support
---------------------------------
- Developed by Tiago Costa Nº56483
