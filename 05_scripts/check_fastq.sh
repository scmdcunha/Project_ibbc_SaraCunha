#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Detect matching R2 based on R1
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


# Validate FASTQ structure
validate_fastq() {
    local file="$1"
    readarray -t lines < <(zcat "$file" 2>/dev/null | head -n 4)

    [[ "${#lines[@]}" -eq 4 ]] || return 1

    local header="${lines[0]}"
    local seq="${lines[1]}"
    local plus="${lines[2]}"
    local qual="${lines[3]}"

    [[ "$header" =~ ^@ ]] || return 1
    [[ "$plus" =~ ^\+ ]] || return 1
    [[ "${#seq}" -eq "${#qual}" ]] || return 1

    return 0
}


# Script start
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

echo "Checking FASTQ files in: $fastq_dir"
echo ""

# Check existence
fastq_count=$(ls "${fastq_dir}"/*.fastq.gz 2>/dev/null | wc -l || true)

if [[ $fastq_count -eq 0 ]]; then
    echo "No FASTQ files found in $fastq_dir"
    exit 1
fi

echo "Number of FASTQ files found: $fastq_count"
echo ""


# Main loop: detect all R1 files
samples=0
errors=0

echo "Checking sample pairs..."
echo ""

for R1 in "$fastq_dir"/*.fastq.gz; do
    # Only process R1-like files
    if [[ "$R1" =~ R1 ]] || [[ "$R1" =~ _1 ]] || [[ "$R1" =~ -1 ]]; then
        :
    else
        continue
    fi

    samples=$((samples+1))
    base_R1=$(basename "$R1")
    R2=$(detect_R2_from_R1 "$R1")

    echo "Sample $samples:"
    echo "  R1: $base_R1"

    if [[ -z "$R2" || ! -f "$R2" ]]; then
        echo "  R2: MISSING"
        errors=$((errors+1))
    else
        echo "  R2: $(basename "$R2") (OK)"
    fi

    echo "  Validating FASTQ structure..."

    if validate_fastq "$R1"; then
        echo "    R1 structure: OK"
    else
        echo "    R1 structure: INVALID FASTQ STRUCTURE"
        errors=$((errors+1))
    fi

    if [[ -f "$R2" ]] && validate_fastq "$R2"; then
        echo "    R2 structure: OK"
    elif [[ -f "$R2" ]]; then
        echo "    R2 structure: INVALID FASTQ STRUCTURE"
        errors=$((errors+1))
    fi

    echo ""
done


# Summary
echo "Summary:"
echo "  Total samples detected: $samples"
echo "  Total issues detected:  $errors"

if [[ $errors -gt 0 ]]; then
    echo "Some samples are missing pairs or have invalid FASTQ structure."
    exit 2
else
    echo "All paired-end files detected and valid!"
fi

echo ""
