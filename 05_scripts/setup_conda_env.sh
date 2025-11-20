#!/bin/bash
set -euo pipefail

env_name="tools_qc"

# verify if the environment already exists
if conda env list | grep -qE "^${env_name}[[:space:]]"; then
    echo "Environment ${env_name} already exists."
    exit 0
fi

echo "Creating environment ${env_name}..."

# create environment
conda create -n ${env_name} \
    fastqc=0.12.1 \
    trimmomatic=0.40 \
    multiqc=1.31

echo "Environment ${env_name} created successfully."

# export environment for reproducibility
echo "Exporting environment ${env_name}..."
conda env export -n ${env_name} > ${env_name}.yml

echo "Environment ${env_name} exported successfully."

echo "Usage:"
echo "conda activate ${env_name}"
