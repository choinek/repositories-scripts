#!/bin/bash

# Input script file
SCRIPT_FILE="install2-trash.sh"

# Read and process each line
echo "Dry run: Replacing 'echo -e' with 'printf'"
echo "Processing file: $SCRIPT_FILE"
echo

# Iterate through the script line by line
while IFS= read -r line; do
    if [[ "$line" =~ echo[[:space:]]-e ]]; then
        # Extract the content inside echo -e
        original_content=$(echo "$line" | sed -E 's/^[[:space:]]*echo[[:space:]]-e[[:space:]]*//')

        # Generate the replacement
        replacement="printf ${original_content//\"/\\\"}\\n"

        echo "Found: $line"
        echo "Replacement: $replacement"
        echo "---"
    fi
done < "$SCRIPT_FILE"

echo "Dry run completed. No changes were made to the file."
