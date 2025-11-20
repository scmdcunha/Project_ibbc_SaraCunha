# Overview

This repository provides a small, portable pipeline for quality-control and trimming of paired-end FASTQ sequencing data.
The workflow includes:

**FastQC** on raw reads
**MultiQC** summarising raw QC
**Trimmomatic** for trimming/cleaning
**FastQC** on trimmed reads
**MultiQC** final summary

All steps are automated through 'run_pipeline.sh'.

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

Your files must follow a naming pattern such as:

```
sampleID_1_*.fastq.gz
sampleID_2_*.fastq.gz
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

## 4. Run the full pipeline

Execute all steps (FastQC → MultiQC → Trimmomatic → FastQC trimmed → MultiQC final) with:

```bash
bash 05_scripts/run_pipeline.sh
```

Results will appear under:

```
03_results/
```

Logs for every step are written to:

```
04_logs/
```

## 5. Output structure

After running the pipeline, expect:

```
03_results/
    fastqc_raw/
    multiqc_raw/
    trimmed/
    fastqc_trimmed/
    multiqc_final/
```

## 6. Re-running the pipeline

If you need a clean restart, delete previous results:

```bash
rm -rf 03_results/*
```

Then run the pipeline again.
