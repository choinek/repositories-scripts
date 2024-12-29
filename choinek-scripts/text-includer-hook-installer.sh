#!/bin/bash

HOOK_FILE=".git/hooks/pre-commit"
INCLUDER_SCRIPT=".choinek-scripts/text-includer.sh"

if [[ ! -d ".git" ]]; then
    echo "Error: This script must be run from the root of a Git repository."
    exit 1
fi

read -p "Enter the path to the source file (e.g., README.md.source): " SOURCE_FILE
read -p "Enter the path to the output file (e.g., README.md): " OUTPUT_FILE

if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "Error: Source file $SOURCE_FILE does not exist."
    exit 1
fi

START_TAG="###> text-includer.sh ###"
END_TAG="###< text-includer.sh ###"

SCRIPT_BLOCK=$(cat <<EOF
$START_TAG
export SOURCE_FILE="$SOURCE_FILE"
export OUTPUT_FILE="$OUTPUT_FILE"
bash $INCLUDER_SCRIPT
$END_TAG
EOF
)

if [[ -f "$HOOK_FILE" ]]; then
    if grep -q "$START_TAG" "$HOOK_FILE"; then
        sed -i "/$START_TAG/,/$END_TAG/c\\$SCRIPT_BLOCK" "$HOOK_FILE"
    else
        printf "\n%s\n" "$SCRIPT_BLOCK" >> "$HOOK_FILE"
    fi
else
    printf "#!/bin/sh\n\n%s\n" "$SCRIPT_BLOCK" > "$HOOK_FILE"
fi

chmod +x "$HOOK_FILE"

echo "Pre-commit hook installed successfully."
echo "Source file: $SOURCE_FILE"
echo "Output file: $OUTPUT_FILE"
