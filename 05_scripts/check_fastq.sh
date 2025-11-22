#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Check argument
if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <fastq_directory>"
    exit 1
fi
