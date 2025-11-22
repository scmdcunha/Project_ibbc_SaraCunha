#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

validate_fastq() {
    local file="$1"
    readarray -t lines < <(zcat "$file" 2>/dev/null | head -n 4)

    local header="${lines[0]}"
    local seq="${lines[1]}"
    local plus="${lines[2]}"
    local qual="${lines[3]}"

    [[ "$header" =~ ^@ ]] || return 1
    [[ "$plus" =~ ^\+ ]] || return 1
    [[ "${#seq}" -eq "${#qual}" ]] || return 1

    return 0
}

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <fastq_dir>"
    exit 1
fi

fastq_dir=$1
log_dir="04_logs/check_fastq"
mkdir -p "$log_dir"

timestamp=$(date +"%Y%m%d_%H%M%S")
log_file="${log_dir}/check_fastq_${timestamp}.log"

exec > >(tee -a "$log_file") 2>&1

echo "Checking FASTQ files in $fastq_dir"
echo "Directory: $fastq_dir"
echo ""

# Check if fastq files exist
fastq_count=$(ls "${fastq_dir}"/*.fastq.gz 2>/dev/null | wc -l || true)

if [[ $fastq_count -eq 0 ]]; then
    echo "No FASTQ files found in $fastq_dir"
    exit 1
fi

echo "Number of FASTQ files: $fastq_count"
echo ""

# Identify samples (prefix before _1_)
samples=0
errors=0

echo "Checking sample pairs:"
echo ""

for R1 in "${fastq_dir}"/*_1_*.fastq.gz; do
    [[ -e "$R1" ]] || continue

    samples=$((samples+1))
    base=$(basename "$R1")

    sample=$(echo "$base" | sed 's/_1_.*fastq.gz//')

    suffix=$(echo "$base" | sed 's/.*_1_\(.*\)\.fastq\.gz/\1/')

    R2="${fastq_dir}/${sample}_2_${suffix}.fastq.gz"

    echo "Sample: $sample"
    echo "R1: $base"

    if [[ -f "$R2" ]]; then
        echo "  R2: $(basename "$R2") (OK)"
    else
        echo "  R2: Missing! File not found."
        errors=$((errors+1))
    fi

    echo ""

    echo "Validating FASTQ structure:"

    if validate_fastq "$R1"; then
        echo "  R1 structure: OK"
    else
        echo "  R1: Invalid FASTQ structure"
        errors=$((errors+1))
    fi

    if validate_fastq "$R2"; then
        echo "  R2 structure: OK"
    else
        echo "  R2: Invalid FASTQ structure"
        errors=$((errors+1))
    fi

    echo ""
done

echo "Summary:"
echo "Samples: $samples"
echo "Missing pairs: $errors"

if [[ $errors -gt 0 ]]; then
    echo "Some samples have missing R2 files."
    exit 2
else
    echo "All samples have both R1 and R2 files."
fi

echo ""
