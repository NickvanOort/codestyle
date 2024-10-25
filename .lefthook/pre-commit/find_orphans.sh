#!/bin/bash

# Get all md files (excluding README.md as it's typically the entry point)
files=$(find . -name "*.md" ! -name "README.md")

# Initialize array for orphaned files
orphaned=()

for file in $files; do
    # Get filename without path
    filename=$(basename "$file")
    # Search for references to this file in all md files
    # We search for both [text](filename) and plain filename references
    if ! grep -r --include="*.md" -l "$filename" . | grep -v "$file" > /dev/null; then
        orphaned+=("$filename")
    fi
done

if [ ${#orphaned[@]} -eq 0 ]; then
    echo "No orphaned files found!"
else
    echo "Found ${#orphaned[@]} orphaned files:"
    printf '%s\n' "${orphaned[@]}"
fi
