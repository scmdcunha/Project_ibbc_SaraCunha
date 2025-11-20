#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# config

# Check arguments
if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <input_fastq_dir> <output_trimmed_dir>"
    exit 1
fi

env_name="tools_qc"
data_dir="$1"
trim_dir="$2"
log_dir="04_logs/trimmomatic"

mkdir -p "$trim_dir"
mkdir -p "$log_dir"

timestamp=$(date +%Y%m%d_%H%M%S)
log_file="${log_dir}/trimmomatic_${timestamp}.log"

exec > >(tee "$log_file") 2>&1

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate "$env_name"

echo "Running Trimmomatic"
echo "  Input FASTQ dir:   $data_dir"
echo "  Output trimmed dir: $trim_dir"

# Loop over samples and run Trimmomatic
for R1 in "$data_dir"/*_1*.fastq.gz; do
    sample=$(basename "$R1" | sed 's/_1.*fastq.gz//')

    # detect R2
    R2=$(ls "$data_dir"/"${sample}"_2*.fastq.gz 2>/dev/null || true)

    if [[ -z "$R2" ]]; then
        echo "Skipping sample $sample (R2 not found)"
        continue
    fi

    echo "Processing sample $sample"
    echo "  R1: $R1"
    echo "  R2: $R2"

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

    echo "Done: $sample"
done

echo "Trimming completed"

# deactivate conda environment
conda deactivate
