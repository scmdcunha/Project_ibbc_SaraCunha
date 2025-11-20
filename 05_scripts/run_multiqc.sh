#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# config

env_name="tools_qc"
results_dir="03_results"
multiqc_dir="03_results/multiqc"
log_dir="04_logs/multiqc"

mkdir -p "$multiqc_dir"
mkdir -p "$log_dir"

log_file="${log_dir}/multiqc_$(date +%Y%m%d%H%M%S).log"
exec > >(tee "$log_file") 2>&1

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate "$env_name"

echo "Running MultiQC..."

# Run MultiQC
multiqc "$results_dir" -o "$multiqc_dir"

echo "MultiQC completed successfully."
echo "Report saved at $multiqc_dir"

# Deactivate conda environment
conda deactivate
