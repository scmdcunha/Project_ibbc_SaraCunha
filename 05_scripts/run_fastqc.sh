#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# config

# Check number of args
if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <input_fastq_dir> <output_fastqc_dir>"
    exit 1
fi

env_name="tools_qc"
data_dir="$1"
output_dir="$2"
log_dir="04_logs/fastqc"

mkdir -p "$output_dir"
mkdir -p "$log_dir"

timestamp=$(date +%Y%m%d%H%M%S)
log_file="${log_dir}/fastqc_$(basename "$output_dir")_${timestamp}.log"

exec > >(tee "$log_file") 2>&1

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate "$env_name"

echo "Running FastQC on: $data_dir"
echo "Saving output to: $output_dir"

# Loop over samples and run FastQC
for R1 in "$data_dir"/*_1_*.fastq.gz; do
    sample=$(basename "$R1" | sed 's/_1_.*fastq.gz//')

    R2=$(ls "$data_dir"/"${sample}"_2_*.fastq.gz 2>/dev/null || true)


    if [[ -z "$R2" ]]; then
        echo "Skipping sample $sample (R2 not found)"
        continue
    fi

    echo "Running FastQC on sample $sample"
    fastqc -o "$output_dir" "$R1" "$R2"
done

# Deactivate conda environment
conda deactivate
