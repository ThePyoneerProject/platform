#!/bin/bash

# Set the directory to start from
ROOT_DIR="."

# Set the output file
OUTPUT_FILE="aggregated_content.txt"

# Define blacklist directories, files, and extensions
BLACKLIST_DIRS="(.git|.idea|.next|node_modules|media|img|svg|.terraform|js)"
BLACKLIST_FILES="(package-lock.json|output.css|.DS_Store)"
BLACKLIST_EXTS="(\.exe|\.tmp|\.env|\.gitignore|\.svg|\.ico)"

# Check if output file exists, delete it if it does
[ -f "$OUTPUT_FILE" ] && rm "$OUTPUT_FILE"

# Loop through all files in the directory and subdirectories
find "$ROOT_DIR" -type f | while read -r file; do
    if [[ $file =~ $BLACKLIST_DIRS ]] || [[ $file =~ $BLACKLIST_FILES ]] || [[ $file =~ $BLACKLIST_EXTS ]]; then
        #echo "Skipping: $file"
        continue
    else
        echo "Processing: $file"
        echo "FILE: $file" >> "$OUTPUT_FILE"
        cat "$file" >> "$OUTPUT_FILE"
        echo -e "\n-----\n" >> "$OUTPUT_FILE"
    fi
done

echo "Done. Check $OUTPUT_FILE for the content."
