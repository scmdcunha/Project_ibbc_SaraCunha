#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Check args
if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <input_fastq_dir> <output_fastqc_dir>"
    exit 1
fi

env_name="tools_qc"
data_dir="$1"
output_dir="$2"

log_dir="04_logs/fastqc"
mkdir -p "$output_dir" "$log_dir"

timestamp=$(date +%Y%m%d%H%M%S)
log_file="${log_dir}/fastqc_$(basename "$output_dir")_${timestamp}.log"
exec > >(tee "$log_file") 2>&1

source ~/miniconda3/etc/profile.d/conda.sh
conda activate "$env_name"

# Function to detect R2 from R1
detect_R2_from_R1() {
    local r1="$1"

    if [[ "$r1" =~ R1 ]]; then
        echo "${r1/R1/R2}"
    elif [[ "$r1" =~ _1_ ]]; then
        echo "${r1/_1_/_2_}"
    elif [[ "$r1" =~ _1 ]]; then
        echo "${r1/_1/_2}"
    elif [[ "$r1" =~ -1 ]]; then
        echo "${r1/-1/-2}"
    else
        echo ""
    fi
}

echo ""
echo "Running FastQC on paired reads"
echo "Input dir:  $data_dir"
echo "Output dir: $output_dir"
echo ""

# Running fastqc on paired reads
for R1 in "$data_dir"/*.fastq.gz; do

    # Only treat files with R1 pattern
    if [[ "$R1" =~ unpaired ]]; then
        continue
    fi

    if [[ "$R1" =~ R1 ]] || [[ "$R1" =~ _1 ]] || [[ "$R1" =~ -1 ]]; then
        :
    else
        continue
    fi

    R2=$(detect_R2_from_R1 "$R1")

    if [[ -z "$R2" || ! -f "$R2" ]]; then
        echo "Skipping $(basename "$R1"): missing R2 pair"
        continue
    fi

    echo "FASTQC on:"
    echo "  R1 = $(basename "$R1")"
    echo "  R2 = $(basename "$R2")"

    fastqc -o "$output_dir" "$R1" "$R2"
done

conda deactivate
echo ""
echo "Done."
