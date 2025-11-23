# Overview

This repository provides a small, portable pipeline for quality-control and trimming of paired-end FASTQ sequencing data.
The workflow performs:

- **FastQC** on raw reads
- **MultiQC** summarising raw QC
- **Trimmomatic** trimming (configurable via `02_metadata/trimming_config.txt`)
- **FastQC** on trimmed reads
- **MultiQC** final summary

All steps are automated through `run_pipeline.sh`.

# Usage

## 1. Create the project structure

Before running the pipeline, generate the folder layout using:

```bash
bash create_project_structure.sh <project_name>
```
This will create:

```
01_data/
02_metadata/
03_results/
04_logs/
05_scripts/
```

## 2. Add your FASTQ files

After creating the structure, copy or move your paired-end FASTQ files into:

```
01_data/
```

## 3. Install the required conda environment

The pipeline uses a dedicated environment containing:

- FastQC
- Trimmomatic
- MultiQC

Create it using:

```bash
bash 05_scripts/setup_conda_env.sh
```

## 4. Configure trimming parameters

Edit: 

```
02_metadata/trimming_config.txt
```
You can modify any of the following fields:

```
HEAD_CROP=12
LEADING_QUAL=3
TRAILING_QUAL=3
SLIDINGWINDOW=4:20
MINLEN=36
```
For a full explanation of each parameter, consult the official Trimmomatic manual:

[http://www.usadellab.org/cms/?page=trimmomatic]

These values are loaded automatically by the trimming script.

## 5. Run the full pipeline

Execute:

```bash
bash 05_scripts/run_pipeline.sh
```

This runs:

1. FASTQ validation (check_fastq.sh)
2. FastQC on raw reads
3. MultiQC raw
4. Trimmomatic trimming
5. FastQC on trimmed reads
6. MultiQC final

Results will appear under:

```
03_results/
```

## 6. Output structure

After running the pipeline, expect:

```
03_results/
    fastqc_raw/
    multiqc_raw/
    trimmed/
    fastqc_trimmed/
    multiqc_final/
```

Logs for every step:

```
04_logs/
```

## 7. Re-running the pipeline

If you need a clean restart, delete previous results:

```bash
rm -rf 03_results/*
```

Then run the pipeline again.

## 8. Adjusting trimming and re-processing samples

If FastQC/MultiQC reports indicate:

- remaining adapter sequence
- poor quality at read start
- unusual per-base content
- excessive drop in quality

update trimming parameters in:

```
02_metadata/trimming_config.txt
```

and re-run:

```bash
bash 05_scripts/run_trimmomatic.sh 01_data 03_results/trimmed
bash 05_scripts/run_fastqc.sh 03_results/trimmed 03_results/fastqc_trimmed
bash 05_scripts/run_multiqc.sh 03_results/fastqc_trimmed 03_results/multiqc_final
```

# References

**FastQC** - “Babraham Bioinformatics - FastQC A Quality Control tool for High Throughput Sequence Data.” Accessed: Nov. 23, 2025. [Online]. Available: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

**MultiQc** - “MultiQC | Seqera.” Accessed: Nov. 23, 2025. [Online]. Available: https://seqera.io/multiqc/

**Trimmomatic** - “USADELLAB.org - Trimmomatic: A flexible read trimming tool for Illumina NGS data.” Accessed: Nov. 23, 2025. [Online]. Available: http://www.usadellab.org/cms/?page=trimmomatic

---

The project includes the three required components:

1. Script for creating the project structure

`create_project_structure.sh`

2. Scripts for processing paired-end FASTQ samples

These scripts together implement the full FASTQ processing workflow:

- `run_pipeline.sh` → orchestrates all steps
- `run_fastqc.sh` → FastQC on raw/trimmed reads
- `run_multiqc.sh` → MultiQC summarisation
- `run_trimmomatic.sh` → read trimming (parameters customisable via `02_metadata/trimming_config.txt`)

All logs are written to `04_logs/`

3. Additional script (“third script”)

`check_fastq.sh`

This custom script validates:

- FASTQ file structure
- detection of R1/R2 pairs
- correct naming patterns

It is executed automatically at the beginning of the pipeline to prevent invalid inputs.

# Author

This project was developed by Sara Cunha as part of the Bash Scripting evaluation for the course *Introduction to Bioinformatics and Computational Biology*.
