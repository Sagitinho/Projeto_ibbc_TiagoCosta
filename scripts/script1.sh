#!/bin/bash
set -euo pipefail

# ------------------------------------------
#  -- HELP OPTION
# ------------------------------------------
if [[ "${1:-}" == "--help" ]]; then
    echo "Usage: $0 <Identifier>"
    echo
    echo "Creates a project directory structure for bioinformatics workflows."
    echo "Example:"
    echo "  ./script1.sh Sample01"
    exit 0
fi

# ------------------------------------------
#  -- ARGUMENT CHECK
# ------------------------------------------
if [ $# -ne 1 ]; then
    echo "Error: You must provide exactly one identifier."
    echo "Use --help for instructions."
    exit 1
fi

IDENTIFIER="$1"

# ------------------------------------------
#  -- DIRECTORY STRUCTURE
# ------------------------------------------
SUB_DIRS=(
    "1_raw_data"
    "2_metadata"
    "3_trimmed_data"
    "4_alignment"
    "5_results"
    "scripts"
    "logs"
)

FULL_PATH="Project_ibbc_${IDENTIFIER}"
echo "Creating directory structure for $FULL_PATH..."

mkdir -p "$FULL_PATH"

# ------------------------------------------
#  -- LOGGING SETUP
# ------------------------------------------
LOG_FILE="${FULL_PATH}/logs/setup.log"
mkdir -p "${FULL_PATH}/logs"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "Logging enabled. All output will be saved to: $LOG_FILE"
echo "-----------------------------------------------"

# ------------------------------------------
#  -- GENERATING SUBDIRECTORIES
# ------------------------------------------
for dir in "${SUB_DIRS[@]}"; do
    SUB_DIR_PATH="${FULL_PATH}/${dir}"

    if [ -d "$SUB_DIR_PATH" ]; then
        echo "Subdirectory $dir already exists."
    else
        echo "Creating subdirectory $dir..."
        mkdir -p "$SUB_DIR_PATH"
    fi
done

# ------------------------------------------
#  -- COPY SCRIPT1.SH AND OTHER .SH FILES
# ------------------------------------------
# Safely get the folder where this script lives
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-${0}}" )" &> /dev/null && pwd )"
TARGET_SCRIPTS_DIR="${FULL_PATH}/scripts"

# Copy this setup script itself
echo "Copying script1.sh to $TARGET_SCRIPTS_DIR..."
cp -u "${SCRIPT_DIR}/script1.sh" "$TARGET_SCRIPTS_DIR"/

# Copy other .sh files in the same folder
for file in "$SCRIPT_DIR"/*.sh; do
    if [[ "$(basename "$file")" != "script1.sh" ]]; then
        echo "Copying $file to $TARGET_SCRIPTS_DIR..."
        cp -u "$file" "$TARGET_SCRIPTS_DIR"/
    fi
done

echo "All scripts copied to $TARGET_SCRIPTS_DIR."

# ------------------------------------------
#  -- FINAL MESSAGE
# ------------------------------------------
echo "-----------------------------------------------"
echo "Script completed successfully!"
echo "Directory structure for Project_ibbc_${IDENTIFIER} is ready."
echo "Logs saved in: $LOG_FILE"
