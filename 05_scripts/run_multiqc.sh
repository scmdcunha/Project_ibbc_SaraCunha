#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# config

# Check arguments
if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <input_results_dir> <output_multiqc_dir>"
    exit 1
fi

env_name="tools_qc"
input_dir="$1"
output_dir="$2"
log_dir="04_logs/multiqc"

mkdir -p "$output_dir"
mkdir -p "$log_dir"

timestamp=$(date +%Y%m%d%H%M%S)
log_file="${log_dir}/multiqc_$(basename "$output_dir")_${timestamp}.log"

exec > >(tee "$log_file") 2>&1

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate "$env_name"

echo "Running MultiQC..."
echo "  Input:  $input_dir"
echo "  Output: $output_dir"

# Run MultiQC
multiqc "$input_dir" -o "$output_dir"

echo "MultiQC completed successfully."
echo "Report saved at $output_dir"

# Deactivate conda environment
conda deactivate
