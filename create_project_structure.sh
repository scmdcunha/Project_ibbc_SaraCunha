#!/bin/bash

# Check if user passed a project project_name
if [ -z "$1" ]; then
    echo "Please provide a project name as an argument."
    echo "Usage: $0 <project_name>"
    exit 1
fi

# variables
base_dir="$HOME"
project_name="$1"
project_dir="$base_dir/$project_name"

# create project structure if it doesn't exist
if [ -d "$project_dir" ]; then
    if [ -z "$(ls -A "$project_dir")" ]; then
        echo " Directory $project_name already exists but is empty. Creating structure"
    else
        echo "Directory $project_name already exists."
        echo "Aborting to avoid overwriting existing data"
        exit 1
    fi
else
    echo "Directory $project_name does not exist. Creating it..."
    mkdir -p "$project_dir"

fi

# Create structure
mkdir -p "$project_dir/01_data"
mkdir -p "$project_dir/02_metadata"
mkdir -p "$project_dir/03_results/fastqc_raw"
mkdir -p "$project_dir/03_results/trimmed"
mkdir -p "$project_dir/03_results/fastqc_trimmed"
mkdir -p "$project_dir/03_results/multiqc"
mkdir -p "$project_dir/04_logs"
mkdir -p "$project_dir/05_scripts"

# create a README file
touch "$project_dir/README.md"

echo "Project structure created."
