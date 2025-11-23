#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Check arguments
if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <input_fastq_dir> <output_trimmed_dir>"
    exit 1
fi

# Detect matching R2 from R1
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

env_name="tools_qc"
data_dir="$1"
trim_dir="$2"
log_dir="04_logs/trimmomatic"
config_file="02_metadata/trimming_config.txt"

mkdir -p "$trim_dir" "$log_dir"

timestamp=$(date +"%Y%m%d_%H%M%S")
log_file="${log_dir}/trimmomatic_${timestamp}.log"
exec > >(tee "$log_file") 2>&1

# Load configuration
if [[ ! -f "$config_file" ]]; then
    echo "ERROR: Config file not found at $config_file"
    exit 1
fi

echo "Loading trimming configuration from $config_file"
source "$config_file"
echo ""

# Activate conda
source ~/miniconda3/etc/profile.d/conda.sh
conda activate "$env_name"

echo "Running Trimmomatic"
echo "Input FASTQ dir:    $data_dir"
echo "Output trimmed dir: $trim_dir"
echo ""

# Detect adapters inside the conda environment
ADAPTERS=$(ls $CONDA_PREFIX/share/trimmomatic*/adapters/TruSeq3-PE.fa 2>/dev/null | head -n 1 || true)

if [[ -z "$ADAPTERS" ]]; then
    echo "ERROR: Could not find TruSeq3-PE.fa in conda environment!"
    exit 1
fi

echo "Using adapters: $ADAPTERS"
echo ""

# Loop over R1 files
for R1 in "$data_dir"/*.fastq.gz; do

    # detect R1 pattern
    if [[ "$R1" =~ R1 ]] || [[ "$R1" =~ _1 ]] || [[ "$R1" =~ -1 ]]; then
        :
    else
        continue
    fi

    # Extract sample prefix
    sample=$(basename "$R1" | sed 's/\(R1\|_1\|-1\).*//')

    # Detect R2
    R2=$(detect_R2_from_R1 "$R1")

    if [[ -z "$R2" || ! -f "$R2" ]]; then
        echo "Skipping sample $sample (R2 not found)"
        continue
    fi

    echo "Processing sample: $sample"
    echo "  R1 = $R1"
    echo "  R2 = $R2"

    out_R1="${trim_dir}/${sample}_1_trimmed.fastq.gz"
    out_unp_R1="${trim_dir}/${sample}_1_unpaired.fastq.gz"
    out_R2="${trim_dir}/${sample}_2_trimmed.fastq.gz"
    out_unp_R2="${trim_dir}/${sample}_2_unpaired.fastq.gz"

    # Trimmomatic Command
    trimmomatic PE \
        -threads 4 \
        -phred33 \
        "$R1" "$R2" \
        "$out_R1" "$out_unp_R1" \
        "$out_R2" "$out_unp_R2" \
        ILLUMINACLIP:"$ADAPTERS":2:30:10 \
        HEADCROP:${HEAD_CROP} \
        LEADING:${LEADING_QUAL} \
        TRAILING:${TRAILING_QUAL} \
        SLIDINGWINDOW:${SLIDINGWINDOW} \
        MINLEN:${MINLEN}

    echo "Done: $sample"
    echo ""
done

echo "Trimming completed"
conda deactivate
