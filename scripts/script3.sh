#!/bin/bash

# -------------------------------------------
# Script 3 - MultiQC summary
# -------------------------------------------

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: bash $0 <ProjectName>"
    exit 1
fi

PROJECT_NAME=$1
PROJECT="Project_ibbc_${PROJECT_NAME}"
RESULTS_DIR="$PROJECT/5_results"
MULTIQC_DIR="$RESULTS_DIR/multiqc"

# Create MultiQC output directory
mkdir -p "$MULTIQC_DIR"

echo "-----------------------------------------------"
echo "Project: $PROJECT"
echo "Running MultiQC on available results in $RESULTS_DIR ..."
echo "Output will be saved in $MULTIQC_DIR"
echo "-----------------------------------------------"

# Run MultiQC
multiqc "$RESULTS_DIR" -o "$MULTIQC_DIR" --interactive

echo "MultiQC done!"
