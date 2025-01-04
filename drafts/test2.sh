#!/bin/bash

# Input script file
SCRIPT_FILE="install2-trash.sh"

# Backup the original file
cp "$SCRIPT_FILE" "${SCRIPT_FILE}.bak"
echo "Backup created: ${SCRIPT_FILE}.bak"

# Replacement logic
sed -i '' -E \
    -e 's/echo -e[[:space:]]*"\$\(echo -e ([^"]+)\)"/read -p "$(printf "%s\\n" \1)" response/' \
    -e 's/echo -e "([^\"]+)"/printf "%s\\n" "\1"/g' \
    -e 's/\$\(echo -e ([^"]+)\)/\$(printf "%s" \1)/g' \
    "$SCRIPT_FILE"

echo "Replacements complete. The file has been updated."

# Instructions for validation
echo "Validate your changes. The original file is backed up as ${SCRIPT_FILE}.bak."
