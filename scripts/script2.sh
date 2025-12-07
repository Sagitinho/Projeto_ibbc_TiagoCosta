#!/bin/bash

# -------------------------------------------
# Script 2 - Pipeline de QC e trimming
# -------------------------------------------

# Checar argumentos
if [ $# -lt 2 ]; then
    echo "Uso: bash $0 <ProjectName> <mode>"
    echo "Modes: fastqc | fastp | organelle"
    exit 1
fi

PROJECT_NAME=$1
MODE=$2

PROJECT="Project_ibbc_${PROJECT_NAME}"
RAW_DIR="$PROJECT/1_raw_data"
TRIMMED_DIR="$PROJECT/3_trimmed_data"

# Criar pastas de resultados/logs se não existirem
mkdir -p "$PROJECT/3_trimmed_data"
mkdir -p "$PROJECT/5_results/fastqc"
mkdir -p "$PROJECT/5_results/fastp"
mkdir -p "$PROJECT/logs"
mkdir -p "$PROJECT/5_results/getorganelle"

LOG_FILE="$PROJECT/logs/${MODE}.log"

echo "-----------------------------------------------"
echo "Project: $PROJECT"
echo "Mode: $MODE"
echo "Logging to: $LOG_FILE"
echo "-----------------------------------------------"

# Redirecionar saída para log
exec > >(tee -a "$LOG_FILE") 2>&1

# -------------------------------
# FASTQC
# -------------------------------
if [ "$MODE" == "fastqc" ]; then
    echo "Running FastQC on all raw FASTQ files in $RAW_DIR ..."
    for FILE in "$RAW_DIR"/*.fastq.gz; do
        BASENAME=$(basename "$FILE" .fastq.gz)
        OUTDIR="$PROJECT/5_results/fastqc/$BASENAME"
        mkdir -p "$OUTDIR"
        echo "FastQC → $FILE"
        fastqc -o "$OUTDIR" "$FILE"
    done
    echo "FastQC done!"
    exit 0
fi

# -------------------------------
# fastp
# -------------------------------
if [ "$MODE" == "fastp" ]; then
    echo "Detecting FASTQ files in $RAW_DIR ..."
    FILES=("$RAW_DIR"/*.fastq.gz)
    echo "Files found:"
    for i in "${!FILES[@]}"; do
        echo "  [$i] $(basename "${FILES[$i]}")"
    done

    read -p "Enter the number of the file to process, or 'all' to process all files: " SELECTION

    if [ "$SELECTION" == "all" ]; then
        SELECTED_FILES=("${FILES[@]}")
    else
        SELECTED_FILES=("${FILES[$SELECTION]}")
    fi

    for FILE in "${SELECTED_FILES[@]}"; do
        BASENAME=$(basename "$FILE" .fastq.gz)
        TRIMMED="$TRIMMED_DIR/${BASENAME}_trimmed.fastq.gz"
        JSON_REPORT="$PROJECT/5_results/fastp/${BASENAME}_fastp.json"
        HTML_REPORT="$PROJECT/5_results/fastp/${BASENAME}_fastp.html"

        echo "Running fastp → $TRIMMED"
        fastp -i "$FILE" -o "$TRIMMED" -j "$JSON_REPORT" -h "$HTML_REPORT" -w 4
    done
    echo "FASTP done!"
    exit 0
fi

# -------------------------------
# GetOrganelle
# -------------------------------
if [ "$MODE" == "organelle" ]; then
    echo "-----------------------------------------------"
    echo "Project: $PROJECT"
    echo "Mode: organelle"
    echo "Logging to: $LOG_FILE"
    echo "-----------------------------------------------"

    echo "Detecting trimmed FASTQ files in $TRIMMED_DIR ..."
    FILES=("$TRIMMED_DIR"/*_trimmed.fastq.gz)

    if [ ${#FILES[@]} -eq 0 ]; then
        echo "No trimmed FASTQ files found in $TRIMMED_DIR. Run fastp first."
        exit 1
    fi

    echo "Files found:"
    for i in "${!FILES[@]}"; do
        echo "  [$i] $(basename "${FILES[$i]}")"
    done

    read -p "Enter the number of the file to process, or 'all' to process all files: " SELECTION

    if [ "$SELECTION" == "all" ]; then
        SELECTED_FILES=("${FILES[@]}")
    else
        SELECTED_FILES=("${FILES[$SELECTION]}")
    fi

    for FILE in "${SELECTED_FILES[@]}"; do
        BASENAME=$(basename "$FILE" _trimmed.fastq.gz)
        OUTDIR="$PROJECT/5_results/getorganelle/$BASENAME"
        mkdir -p "$OUTDIR"

        echo "Running GetOrganelle → $OUTDIR"
        # Ajustado para single-end; adicione parâmetros extras se necessário
        get_organelle_from_reads.py \
            -u "$FILE" \
            -o "$OUTDIR" \
            -R 10 \
            -k 21,45,65,85,105 \
            -F embplant_pt \
            -t 4 \
            --overwrite
    done

    echo "GetOrganelle done!"
    exit 0
fi


echo "Modo desconhecido: $MODE"
exit 1
