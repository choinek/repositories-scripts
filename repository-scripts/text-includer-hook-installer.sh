#!/bin/bash

HOOK_FILE=".git/hooks/pre-commit"
INCLUDER_SCRIPT=".repository-scripts/text-includer.sh"

usage() {
    echo "Usage: $0 [-s SOURCE_FILE] [-o OUTPUT_FILE] [-k UNIQUE_KEY]"
    echo ""
    echo "Options:"
    echo "  -s, --source     Path to the source file (e.g., .templates/README.md.source)"
    echo "  -o, --output     Path to the output file (e.g., README.md)"
    echo "  -k, --key        Unique key for the script block (optional)"
    echo "  -h, --help       Display this help message"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--source)
            SOURCE_FILE="$2"
            shift
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift
            ;;
        -k|--key)
            UNIQUE_KEY="$2"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown parameter passed: $1"
            usage
            ;;
    esac
    shift
done

if [[ -z "$SOURCE_FILE" ]]; then
    read -p "Enter the path to the source file (e.g., README.md.source): " SOURCE_FILE
fi

if [[ -z "$OUTPUT_FILE" ]]; then
    read -p "Enter the path to the output file (e.g., README.md): " OUTPUT_FILE
fi

DEFAULT_KEY=$(echo "$SOURCE_FILE" | tr '/' '_')_$(echo "$OUTPUT_FILE" | tr '/' '_')
if [[ -z "$UNIQUE_KEY" ]]; then
    echo "A unique key will be generated based on the source and output files."
    echo "Default Unique Key: $DEFAULT_KEY"
    read -p "Enter a unique key [Press enter to use default]: " UNIQUE_KEY
    UNIQUE_KEY=${UNIQUE_KEY:-$DEFAULT_KEY}
else
    echo "Unique Key provided: $UNIQUE_KEY"
fi

if [[ ! -d ".git" ]]; then
    echo "Error: This script must be run from the root of a Git repository."
    exit 1
fi

if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "Error: Source file '$SOURCE_FILE' does not exist."
    exit 1
fi

START_TAG="###> text-includer.sh $UNIQUE_KEY ###"
END_TAG="###< text-includer.sh $UNIQUE_KEY ###"

SCRIPT_BLOCK=$(cat <<EOF
$START_TAG
bash $INCLUDER_SCRIPT "$SOURCE_FILE" "$OUTPUT_FILE"
$END_TAG
EOF
)

if [[ -f "$HOOK_FILE" ]]; then
    if grep -q "$START_TAG" "$HOOK_FILE"; then
        sed -i "/$START_TAG/,/$END_TAG/c\\
$SCRIPT_BLOCK
" "$HOOK_FILE"
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
echo "Unique Key: $UNIQUE_KEY"
