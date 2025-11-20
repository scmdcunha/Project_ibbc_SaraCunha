#!/bin/bash
set -eue pipefail
IFS=$'\n\t'

# config

env_name="tools_qc"
data_dir="01_data"
output_dir="03_results/fastqc_raw"
log_dir="04_logs"

mkdir -p "$output_dir"

log_file="${log_dir}/fastqc_raw_$(date +%Y%m%d%H%M%S).log"
exec > >(tee "$log_file") 2>&1

# Activate conda environment
conda activate "$env_name"
