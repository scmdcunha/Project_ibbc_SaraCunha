#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "Starting pipeline..."

# 1. Running fastqc in raw data
echo "Step 1: FastQC RAW"
bash 05_scripts/run_fastqc.sh 01_data 03_results/fastqc_raw

# 2. MultiQC in raw data
echo "Step 2: MultiQC RAW"
bash 05_scripts/run_multiqc.sh 03_results/fastqc_raw 03_results/multiqc_raw

# 3. Trimmomatic
# echo "Step 3: Trimmomatic"
# bash 05_scripts/run_trimmomatic.sh

# 4. FastQC on trimmed reads
# echo "Step 4: FastQC TRIMMED "
# bash 05_scripts/run_fastqc.sh 03_results/trimmed 03_results/fastqc_trimmed

# 5. MultiQC final
# echo "Step 5: MultiQC FINAL"
# bash 05_scripts/run_multiqc.sh

# echo "Pipeline completed successfully!"
