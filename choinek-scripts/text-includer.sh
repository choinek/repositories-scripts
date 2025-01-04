#!/bin/bash

# check if DRY_RUN set
if [[ -n "$DRY_RUN" ]]; then
    echo "Dry run enabled: Actions will be simulated, and output will be displayed."
fi

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

    if [[ -n "$DRY_RUN" ]]; then
        echo "Simulating copy: $source_file -> $output_file"
    else
        cp "$source_file" "$output_file"
    fi

    grep -oP '{{text-includer:v1:content-of:[^}]+' "$source_file" | while read -r placeholder; do
        IFS=':' read -r file start_marker end_marker <<< "$(echo "$placeholder" | sed 's/{{text-includer:v1:content-of://')"

        if [[ -z "$file" || ! -f "$file" ]]; then
            echo "Error: File $file referenced in placeholder not found."
            continue
        fi

        if [[ -z "$start_marker" && -z "$end_marker" ]]; then
            content=$(cat "$file")
        elif [[ -n "$start_marker" && -z "$end_marker" ]]; then
            content=$(awk "/$start_marker/{flag=1;next}flag" "$file")
        elif [[ -z "$start_marker" && -n "$end_marker" ]]; then
            content=$(awk "/$end_marker/{flag=0}flag; /$end_marker/{exit}" "$file")
        else
            content=$(awk "/$start_marker/{flag=1;next}/$end_marker/{flag=0}flag" "$file")
        fi

        if [[ -n "$DRY_RUN" ]]; then
            echo "Simulating replacement of placeholder '{{text-includer:v1:content-of:${placeholder}}}'"
            echo "Would replace with content from $file:"
            echo "$content"
        else
            sed -i "s|{{text-includer:v1:content-of:${placeholder}}}|${content}|g" "$output_file"
        fi
    done
}

replace_placeholders "$SOURCE_FILE" "$OUTPUT_FILE"

if [[ -n "$DRY_RUN" ]]; then
    echo "Dry run complete. No changes were made."
else
    echo "$OUTPUT_FILE generated successfully."
fi
