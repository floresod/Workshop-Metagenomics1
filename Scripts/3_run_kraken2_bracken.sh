#!/bin/bash

# -------------------- SLURM Directives --------------------

#SBATCH --account=def-hoomandv               # Account name for job charging
#SBATCH --partition=largemem                 # Partition (node type) to run on
#SBATCH --nodes=1                            # Number of nodes requested
#SBATCH --cpus-per-task=40                   # Number of CPUs to use
#SBATCH --mem=50G                            # Total memory requested
#SBATCH --time=1:00:00                       # Maximum job run time (HH:MM:SS)

#SBATCH --output=../Logs/Slurm/%x-%j.out     # Standard output log (%x=job name, %j=job ID)
#SBATCH --error=../Logs/Slurm/%x-%j.err      # Standard error log

# -------------------- Conda environments --------------------

source ~/projects/def-hoomandv/floresod/miniforge3/etc/profile.d/conda.sh
conda activate metagenomics_env 

# -------------------- Define Input and Output Directories --------------

DB_DIR="../Databases/k2_standard_16gb_20240904/"    # Kraken2 + Bracken database
READS_DIR="../Results/trimmed_reads/"            # QC'ed reads
KK2_REPORT_DIR="../Results/kk2_reports/"         # Kraken2 reports
KK2_OUT_DIR="../Results/kk2_outputs/"            # Kraken2 outputs
BRACKEN_DIR="../Results/bracken/"                # Bracken outputs

READ_LENGTH=150  # Read length for Bracken

# -------------------- Create Output and Log Directories --------------------

mkdir -p "$KK2_REPORT_DIR"
mkdir -p "$KK2_OUT_DIR"
mkdir -p "$BRACKEN_DIR"

# -------------------- Run Kraken2 + Bracken --------------------

for r1_file in "$READS_DIR"/*_R1.fastq.gz; do
    filename=$(basename "$r1_file" _R1.fastq.gz)
    r2_file="${READS_DIR}/${filename}_R2.fastq.gz"

    kraken_output="${KK2_OUT_DIR}/${filename}_output.tsv"
    kraken_report="${KK2_REPORT_DIR}/${filename}.tsv"
    bracken_output="${BRACKEN_DIR}/${filename}.tsv"

    # Run Kraken2
    kraken2 --db "$DB_DIR" \
        --output "$kraken_output" \
        --report "$kraken_report" \
        --paired "$r1_file" "$r2_file" \
        --threads 40 \
        --confidence 0.05 \
        --minimum-base-quality 0 \
        --minimum-hit-groups 3

    # Run Bracken
    bracken -d "$DB_DIR" \
        -i "$kraken_report" \
        -o "$bracken_output" \
        -r "$READ_LENGTH"
done

