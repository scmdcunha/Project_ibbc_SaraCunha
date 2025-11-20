#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# config

env_name="tools_qc"
data_dir="01_data"
output_dir="03_results/fastqc_raw"
log_dir="04_logs"

mkdir -p "$output_dir"
mkdir -p "$log_dir"

log_file="${log_dir}/fastqc_raw_$(date +%Y%m%d%H%M%S).log"
exec > >(tee "$log_file") 2>&1

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate "$env_name"

# Loop over samples and run FastQC
for R1 in "$data_dir"/*_1_aaa.fastq.gz; do
    sample=$(basename "$R1" | sed 's/_1_aaa.fastq.gz//')
    R2="${data_dir}/${sample}_2_aaa.fastq.gz"

    echo "Running FastQC on sample $sample"
    fastqc -o "$output_dir" "$R1" "$R2"
done

# Deactivate conda environment
conda deactivate
