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

Data_DIR="../Data/"
OUTPUT_DIR="../Results/trimmed_reads"
UNPAIRED_DIR="../Results/unpaired"
ADAPTERS="../adapters/TruSeq3-PE.fa"
LogDir="../Logs/Slurm/"

# -------------------- Create Output and Log Directories if Needed --------------------
mkdir -p "$OUTPUT_DIR"
mkdir -p "$UNPAIRED_DIR"
mkdir -p "$LogDir"

# -------------------- Run Trimmomatic --------------------
for file in $Data_DIR/*_R1.fastq.gz; do
    base_name=$(basename "$file" _R1.fastq.gz)

    file_r1="${Data_DIR}/${base_name}_R1.fastq.gz"
    file_r2="${Data_DIR}/${base_name}_R2.fastq.gz"

    paired_R1="${OUTPUT_DIR}/${base_name}_R1.fastq.gz"
    unpaired_R1="${UNPAIRED_DIR}/${base_name}_unpaired_R1.fastq.gz"
    paired_R2="${OUTPUT_DIR}/${base_name}_R2.fastq.gz"
    unpaired_R2="${UNPAIRED_DIR}/${base_name}_unpaired_R2.fastq.gz"

    trimmomatic PE -phred33 \
    "$file_r1" "$file_r2" \
    "$paired_R1" "$unpaired_R1" \
    "$paired_R2" "$unpaired_R2" \
    ILLUMINACLIP:"$ADAPTERS":3:30:10:2:true \
    LEADING:15 TRAILING:15 SLIDINGWINDOW:4:20 MINLEN:50
done

