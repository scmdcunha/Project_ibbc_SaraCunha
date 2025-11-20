#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# config
env_name="tools_qc"
data_dir="01_data"
trim_dir="03_results/trimmed"
log_dir="04_logs/trimmomatic"

mkdir -p "$trim_dir"
mkdir -p "$log_dir"

log_file="${log_dir}/trimmomatic_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee "$log_file") 2>&1

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate "$env_name"

echo "Running Trimmomatic"

# Loop over samples and run Trimmomatic
for R1 in "$data_dir"/*_1_aaa.fastq.gz; do
    sample=$(basename "$R1" | sed 's/_1_aaa.fastq.gz//')
    R2="${data_dir}/${sample}_2_aaa.fastq.gz"

    echo "Processing sample $sample"
    echo "R1: $R1"
    echo "R2: $R2"

    out_R1="${trim_dir}/${sample}_1_trimmed.fastq.gz"
    out_unp_R1="${trim_dir}/${sample}_1_unpaired.fastq.gz"
    out_R2="${trim_dir}/${sample}_2_trimmed.fastq.gz"
    out_unp_R2="${trim_dir}/${sample}_2_unpaired.fastq.gz"


    trimmomatic PE \
    -threads 4 \
    "$R1" "$R2" \
    "$out_R1" "$out_unp_R1" \
    "$out_R2" "$out_unp_R2" \
    SLIDINGWINDOW:4:20 \
    MINLEN:50

done

echo "Trimming completed"

# deactivate conda environment
conda deactivate
