#!/bin/bash

if [[ -z "$SOURCE_FILE" || -z "$OUTPUT_FILE" ]]; then
    echo "Error: SOURCE_FILE or OUTPUT_FILE environment variables not set."
    exit 1
fi

if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "Error: Source file $SOURCE_FILE not found."
    exit 1
fi

replace_placeholders() {
    local source_file=$1
    local output_file=$2

    cp "$source_file" "$output_file"

    grep -oP '{{text-includer:v1:content-of:\K[^}]+' "$source_file" | while read -r placeholder; do
        IFS=':' read -r file start_marker end_marker <<< "$placeholder"

        if [[ ! -f "$file" ]]; then
            echo "Error: File $file referenced in placeholder not found."
            exit 1
        fi

        content=$(awk "/$start_marker/{flag=1;next}/$end_marker/{flag=0}flag" "$file")

        sed -i "s|{{text-includer:v1:content-of:${placeholder}}}|${content}|g" "$output_file"
    done
}

replace_placeholders "$SOURCE_FILE" "$OUTPUT_FILE"
echo "$OUTPUT_FILE generated successfully."
