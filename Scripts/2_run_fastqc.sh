#!/bin/bash

# -------------------- SLURM Directives --------------------

#SBATCH --account=def-hoomandv               # Account name for job charging
#SBATCH --partition=largemem                  # Partition (node type) to run on
#SBATCH --nodes=1                            # Number of nodes requested
#SBATCH --cpus-per-task=40                   # Number of CPUs to use
#SBATCH --mem=50G                            # Total memory requested
#SBATCH --time=1:00:00                       # Maximum job run time (HH:MM:SS)

#SBATCH --output=../Logs/Slurm/%x-%j.out     # Standard output log (%x=job name, %j=job ID)
#SBATCH --error=../Logs/Slurm/%x-%j.err      # Standard error log

# -------------------- Load Conda Environment --------------------
source ~/projects/def-hoomandv/floresod/miniforge3/etc/profile.d/conda.sh
conda activate metagenomics_env 

# -------------------- Define Input and Output Directories --------------------

Data_Directory="../Results/trimmed_reads"                    # Define path to input data directory
Output="../Results/fastqc_trimmed_reads/"                  # Define path to output directory
LogDir="../Logs/Slurm/"                      # Define path to Slurm logs directory

# -------------------- Create Output and Log Directories if Needed --------------------

mkdir -p "$Output"                           # Create Results directory if it doesn't exist
mkdir -p "$LogDir"                           # Create Slurm log directory if it doesn't exist

# -------------------- Run FastQC on All Paired-End Files --------------------

# Loop over all .fastq.gz files in the Data_Directory and run FastQC
for file in "$Data_Directory"/*.fastq.gz
do
    fastqc "$file" --outdir="$Output"        # Run FastQC on each file and send results to output directory
done

