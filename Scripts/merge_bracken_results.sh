#!/bin/bash
set -euo pipefail

# Define directories
INPUT_DIR="../Results/bracken"
OUTPUT_FILE="../Results/combined_bracken_results.tsv"

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Initialize output file with no content
> "$OUTPUT_FILE"

# Track if the header has been written
header_written=false

# Loop over each TSV file
for file in "$INPUT_DIR"/*.tsv; do
    sample=$(basename "$file" .tsv)

    if ! $header_written; then
        # Add header with an extra column "Sample"
        head -n 1 "$file" | awk -F'\t' -v OFS='\t' '{print $0, "Sample"}' > "$OUTPUT_FILE"
        header_written=true
    fi

    # Append content (excluding header), adding Sample column
    tail -n +2 "$file" | awk -F'\t' -v OFS='\t' -v sample="$sample" '{print $0, sample}' >> "$OUTPUT_FILE"
done

echo "Merging complete. Output saved to $OUTPUT_FILE"

