#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo ""
echo "------------------------"
echo "Starting pipeline..."
echo "------------------------"
echo ""


# 0. Check FASTQ files
bash 05_scripts/check_fastq.sh 01_data || {
    echo "FASTQ check failed. Pipeline stopped."
    exit 1
}

# 1. Running fastqc in raw data
echo "Step 1: FastQC RAW"
bash 05_scripts/run_fastqc.sh 01_data 03_results/fastqc_raw
echo "Step 1 completed."
echo ""

# 2. MultiQC in raw data
echo "Step 2: MultiQC RAW"
bash 05_scripts/run_multiqc.sh 03_results/fastqc_raw 03_results/multiqc_raw
echo "Step 2 completed."
echo ""

# 3. Trimmomatic
echo "Step 3: Trimmomatic"
bash 05_scripts/run_trimmomatic.sh 01_data 03_results/trimmed
echo "Step 3 completed."
echo ""

# 4. FastQC on trimmed reads
echo "Step 4: FastQC TRIMMED "
bash 05_scripts/run_fastqc.sh 03_results/trimmed 03_results/fastqc_trimmed
echo "Step 4 completed."
echo ""

# 5. MultiQC final
echo "Step 5: MultiQC FINAL"
bash 05_scripts/run_multiqc.sh 03_results/fastqc_trimmed 03_results/multiqc_final
echo "Step 5 completed."
echo ""

echo "Pipeline completed successfully!"
