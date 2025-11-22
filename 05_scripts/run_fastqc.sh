#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Check number of args (2 or 3)
if [[ "$#" -lt 2 || "$#" -gt 3 ]]; then
    echo "Usage: $0 <input_fastq_dir> <output_fastqc_dir> [r2_pattern]"
    echo "  r2_pattern example: '_2_*.fastq.gz'  or  '_2_trimmed.fastq.gz'"
    exit 1
fi

env_name="tools_qc"
data_dir="$1"
output_dir="$2"
# optional third arg: pattern for R2 suffix (must include leading underscore if relevant)
r2_pattern="${3:-_2_*.fastq.gz}"

log_dir="04_logs/fastqc"
mkdir -p "$output_dir" "$log_dir"

timestamp=$(date +%Y%m%d%H%M%S)
log_file="${log_dir}/fastqc_$(basename "$output_dir")_${timestamp}.log"

exec > >(tee "$log_file") 2>&1

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate "$env_name"

echo "Running FastQC on: $data_dir"
echo "Saving output to: $output_dir"
echo "R2 pattern: $r2_pattern"

# Loop over samples and run FastQC
for R1 in "$data_dir"/*_1_*.fastq.gz; do
    [[ -e "$R1" ]] || continue

    sample=$(basename "$R1" | sed 's/_1_.*fastq.gz//')

    # find the first matching R2 for this sample using the provided pattern
    R2=$(ls ${data_dir}/${sample}${r2_pattern} 2>/dev/null | head -n 1 || true)

    if [[ -z "$R2" ]]; then
        echo "Skipping sample $sample (R2 not found with pattern ${r2_pattern})"
        continue
    fi

    echo "Running FastQC on sample $sample"
    echo "DEBUG: fastqc -o \"$output_dir\" \"$R1\" \"$R2\""
    fastqc -o "$output_dir" "$R1" "$R2"
done

# Deactivate conda environment
conda deactivate
