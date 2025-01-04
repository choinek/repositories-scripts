### Trash to cleanup


#!/bin/bash

INDEX_URL="https://choinek.github.io/scripts/index.json"
SCRIPT_BASE_URL="https://choinek.github.io/scripts/download"

function check_dependencies {
    local dependencies=("curl" "jq" "unzip")
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: '$cmd' is not installed. Please install it and try again."
            exit 1
        fi
    done
}

check_dependencies

if [[ "$(uname)" == "Darwin" ]]; then
    SED_OPTS="-i ''"
else
    SED_OPTS="-i"
fi

if command -v dialog &>/dev/null; then
    USE_DIALOG=true
else
    USE_DIALOG=false
fi

echo "Fetching $INDEX_URL..."
DIRECTORIES=$(curl -sL "$INDEX_URL" | jq -c '.[]')

function show_menu_dialog {
    local options=()
    local index=1
    for dir in $(echo "$DIRECTORIES" | jq -r '.name'); do
        if [[ -d "$dir" ]]; then
            options+=("$index" "[x] $dir")
        else
            options+=("$index" "[ ] $dir")
        fi
        index=$((index + 1))
    done
    dialog --clear --title "choinek/repositories-scripts downloader" \
        --menu "Choose an option:" 20 60 10 "${options[@]}" >/dev/tty 2>&1
}

function show_menu_nodialog {
    echo -e "=== choinek/repositories-scripts downloader ===\n"
    local index=1
    for dir in $(echo "$DIRECTORIES" | jq -r '.name'); do
        if [[ -d "$dir" ]]; then
            echo "[x] $index. $dir"
        else
            echo "[ ] $index. $dir"
        fi
        index=$((index + 1))
    done
    echo -e "\nChoose option (1, 2, ... or enter empty to exit): "
    read -r choice
    echo "$choice"
}

function show_directory_dialog {
    local selected_dir
    selected_dir="$1"
    local dir_data
    dir_data=$(echo "$DIRECTORIES" | jq -r "select(.name == \"$selected_dir\")")
    local name
    name=$(echo "$dir_data" | jq -r '.name')
    local description
    description=$(echo "$dir_data" | jq -r '.description')
    local files
    files=$(echo "$dir_data" | jq -r '.files[]')

    local file_tree=""
    while read -r file; do
        file_tree+="$file\n"
    done <<<"$files"

    dialog --clear --title "$name Downloader" \
        --msgbox "Description: $description\n\nFiles:\n$file_tree" 20 60
}

function show_directory_nodialog {
    local selected_dir="$1"
    local dir_data
    dir_data=$(echo "$DIRECTORIES" | jq -r "select(.name == \"$selected_dir\")")
    local name
    name=$(echo "$dir_data" | jq -r '.name')
    local description
    description=$(echo "$dir_data" | jq -r '.description')
    local files
    files=$(echo "$dir_data" | jq -r '.files[]')

    echo -e "\n=== $name Downloader ==="
    [[ -n "$description" ]] && echo -e "\nDescription: $description\n"
    echo "Files:"
    echo "$files" | while read -r file; do
        echo "├─ $file"
    done
    echo -e "\n1. Download"
    echo "2. Show README"
    echo -e "Choose option (1, 2, or empty to exit): "
    read -r sub_choice
    echo "$sub_choice"
}

function update_gitignore {
    local name="$1"
    local marker_start="###> choinek/repositories-scripts ###"
    local marker_end="###< choinek/repositories-scripts ###"
    local content="$marker_start\n$name\n$marker_end"

    if [[ -f ".gitignore" ]]; then
        if ! grep -q "$name" .gitignore; then
            if grep -q "$marker_start" .gitignore; then
                sed $SED_OPTS "/$marker_start/a\\$name" .gitignore
            else
                echo -e "$content" >>.gitignore
            fi
        fi
    else
        echo -e "$content" >.gitignore
    fi
}

while true; do
    if $USE_DIALOG; then
        choice=$(show_menu_dialog)
    else
        choice=$(show_menu_nodialog)
    fi

    [[ -z "$choice" ]] && break

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > $(echo "$DIRECTORIES" | jq -r '. | length'))); then
        echo "Invalid option. Please try again."
        continue
    fi

    selected_dir=$(echo "$DIRECTORIES" | jq -r ".[$((choice - 1))].name")

    if $USE_DIALOG; then
        show_directory_dialog "$selected_dir"
    else
        sub_choice=$(show_directory_nodialog "$selected_dir")

        [[ -z "$sub_choice" ]] && continue

        case $sub_choice in
        1)
            if [[ -d "$selected_dir" ]]; then
                echo "Warning: Directory '$selected_dir' already exists and will be replaced."
                rm -rf "$selected_dir"
            fi
            echo "Downloading $selected_dir..."
            curl -sL "$SCRIPT_BASE_URL/$selected_dir.zip" -o "$selected_dir.zip"
            unzip -o "$selected_dir.zip"
            update_gitignore "$selected_dir"
            ;;
        2)
            dir_data=$(echo "$DIRECTORIES" | jq -r "select(.name == \"$selected_dir\")")
            description=$(echo "$dir_data" | jq -r '.description')
            echo -e "\nDescription:\n$description\n"
            ;;
        *)
            echo "Invalid option."
            ;;
        esac
    fi
done
