#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

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
