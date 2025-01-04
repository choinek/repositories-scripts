#!/bin/bash

# [CSSH:0.1:START] #
# [CSSH:DESCRIPTION:START] #
# CSSH = Choinek's Standard Shell Handler :) #
# https://github.com/choinek/repository-scripts/tree/main/choinek-shell-scripts #
# Version: 0.1.0 #
# [CSSH:DESCRIPTION:END] #

OSTYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OSTYPE" in
  linux*)   OSTYPE="linux-gnu" ;;
  darwin*)  OSTYPE="darwin" ;;
  bsd*)     OSTYPE="bsd" ;;
  msys*)    OSTYPE="msys" ;;
  cygwin*)  OSTYPE="cygwin" ;;
  *)        OSTYPE="unknown" ;;
esac

beforeVars=($(compgen -v))
beforeVars+=("afterVars" "opt" "PIPESTATUS" "FUNCNAME" "SED_INPLACE")
INDEX_URL="https://choinek.github.io/repository-scripts/index.json"
WEBPAGE_URL="https://choinek.github.io/repository-scripts/"

## [CSSH:OPTS:START] ##
VERBOSE=false
TERMINAL_COLOR=true
TERMINAL_WIDTH=$(stty size 2>/dev/null | awk '{print $2}' || echo 100)
TERMINAL_WIDTH=$((TERMINAL_WIDTH - 2))
BORDER="╒═╕││╘═╛"
ADD_ERROR_INFO="Check $WEBPAGE_URL for help or updates."

while getopts "v-:" opt; do
    case $opt in
    v)
        VERBOSE=true
        ;;
    -)
        case $OPTARG in
        color=*)
            COLOR_OPTION="${OPTARG#color=}"
            if [[ "$COLOR_OPTION" == "false" ]]; then
                TERMINAL_COLOR=false
            elif [[ "$COLOR_OPTION" != "true" ]]; then
                echo "Invalid value for --color: $COLOR_OPTION. Use 'true' or 'false'."
                exit 1
            fi
            ;;
        width=*)
            optWidth="${OPTARG#width=}"
            if ! [[ "$optWidth" =~ ^[0-9]+$ ]]; then
                echo "Invalid width value: $optWidth. Must be a number."
                exit 1
            elif (($optWidth <= 20)); then
                echo "Width must be greater than 20."
                exit 1
            else
                TERMINAL_WIDTH="$optWidth"
            fi
            ;;
        *)
            echo "Invalid option: --$OPTARG" >&2
            echo "Usage: $0 [-v] [--mode=<standalone|composer|>]"
            exit 1
            ;;
        esac
        ;;
    *)
        echo "Invalid option: -$OPTARG" >&2
        echo "Usage: $0 [-v]"
        exit 1
        ;;
    esac
done
## [CSSH:OPTS:END] ##

## [CSSH:OS:START] ##
SUPPORTED_OSTYPES=("linux-gnu" "darwin")

if [[ -z "$OSTYPE" ]]; then
    echo "The OSTYPE environment variable is not set."
    echo "Supported values:"
    for ost in "${SUPPORTED_OSTYPES[@]}"; do
        echo "  - $ost"
    done

    read -p "Please select your OS type from the list above: " user_ostype

    if [[ "${SUPPORTED_OSTYPES[*]} " == *"$user_ostype"* ]]; then
        export OSTYPE="$user_ostype"
        echo "OSTYPE set to $OSTYPE."
    else
        echo "Invalid OSTYPE: $user_ostype. Exiting."
        exit 1
    fi
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_INPLACE=("sed" "-i" "")
else
    SED_INPLACE=("sed" "-i")
fi
## [CSSH:OS:END] ##

## [CSSH:UTILS:START] ##
encode_ansi_sequence() {
    local ansi_sequence="$1"
    echo -n "$ansi_sequence" | base64
}

decode_ansi_sequence() {
    local encoded_sequence="$1"
    echo -n "$encoded_sequence" | base64 --decode
}
## [CSSH:UTILS:END] ##

## [CSSH:UX:START] ##
RESET_COLOR="\033[0m"

etext_optionadv() {
    local color_name=${1}
    local style_name=${2}
    local text=${3}
    local require_verbose=${4}
    local extra_indent=${5:-6}
    local align=${6:-"left"}
    local border_mode=${7:-"integrated"}
    local max_width=${8:-$TERMINAL_WIDTH}
    local force_break_sign=${9}
    local reset_color_suffix=${10:-$RESET_COLOR}

    local color_code=""
    local style_code=""

    case $color_name in
    green) color_code="32" ;;
    bgreen) color_code="92" ;;
    cyan) color_code="36" ;;
    bgblue) color_code="44" ;;
    bgyellow) color_code="43" ;;
    bcyan) color_code="96" ;;
    yellow) color_code="33" ;;
    byellow) color_code="93" ;;
    red) color_code="31" ;;
    white) color_code="97" ;;
    magenta) color_code="95" ;;
    blue) color_code="34" ;;
    bblue) color_code="94" ;;
    *) color_code="" ;;
    esac

    case $style_name in
    bold) style_code="1" ;;
    normal) style_code="0" ;;
    *) style_code="" ;;
    esac

    wrap_text() {
        local input="$1"
        local max_width="$2"
        local first_indent="$3"
        local extra_indent="$4"
        local align="$5"
        local force_break_sign="$6"
        local border_mode="$7"
        local ansi_sequence="$8"

        local left_border="${BORDER_LEFT}"
        local right_border="${BORDER_RIGHT}"

        [[ -z "$border_mode" || "$border_mode" == "none" ]] && left_border="" && right_border=""

        local indent=$(printf "%${first_indent}s")
        local wrapped_text=""
        local first_line=true

        border_left_state=$(printf "%s" "$(get_current_left_border)")
        border_right_state=$(printf "%s" "$(get_current_right_border)")
        left_border=$(printf "%s%s" "$(get_current_left_border)" "$left_border")
        right_border=$(printf "%s%s" "$right_border" "$(get_current_right_border)")

        clean_left_border=$(echo -e "$left_border" | LC_ALL=C sed 's/\x1b\[[0-9;]*m//g')
        clean_right_border=$(echo -e "$right_border" | LC_ALL=C sed 's/\x1b\[[0-9;]*m//g')
        local border_size=$((${#clean_left_border} + ${#clean_right_border}))
        max_width=$((max_width - border_size))

        if [[ "$border_mode" == "full" ]]; then
            wrapped_text+="$border_left_state"
            wrapped_text+=$(printf "%s\n" "$(eline "$max_width" "${BORDER_TOP}" "${BORDER_TOP_LEFT}" "${BORDER_TOP_RIGHT}")")
            wrapped_text+="$border_right_state"
            wrapped_text+=$'\n'
        fi

        local line_width=$((max_width - ${#indent} - border_size - 6))

        while [[ -n $input ]]; do
            local line=""

            if [[ -n "$force_break_sign" && "$force_break_sign" != "false" ]]; then
                if [[ $input == *"$force_break_sign"* ]]; then
                    line="${input%%"$force_break_sign"*}"
                    input="${input#*"$force_break_sign"}"
                else
                    line="$input"
                    input=""
                fi
            else
                if [[ ${#input} -le $line_width ]]; then
                    line="$input"
                    input=""
                else
                    line=$(echo "$input" | grep -oE "^.{1,$line_width}( |$)" | sed 's/[[:space:]]*$//')
                    [[ -z "$line" ]] && line=${input:0:$line_width}
                    input=${input:${#line}}
                    input=$(echo "$input" | sed 's/^[[:space:]]*//')
                fi
            fi

            if $first_line; then
                first_line=false
                indent=$(printf "%${extra_indent}s")
            fi

            local align_length=$((max_width - 2))
            line=$(align_text "${indent}$line" "$align_length" "$align")
            wrapped_text+="${left_border}${line}${right_border}\n"
        done

        if [[ "$border_mode" == "full" ]]; then
            wrapped_text+="$border_left_state"
            wrapped_text+=$(printf "%s\n" "$(eline "$max_width" "${BORDER_BOTTOM}" "${BORDER_BOTTOM_LEFT}" "${BORDER_BOTTOM_RIGHT}")")
            wrapped_text+="$border_right_state"
            wrapped_text+=$'\n'
        fi

        echo -e "$wrapped_text"
    }

    local first_indent
    first_indent=$(echo "$text" | grep -oE "^\s*")
    local indented_text

    local ansi_sequence=""
    if [[ $TERMINAL_COLOR == true && -n $color_code && -n $style_code ]]; then
        ansi_sequence="\033[${style_code};${color_code}m"
        indented_text=$(wrap_text "$text" "$max_width" "$first_indent" "$extra_indent" "$align" "$force_break_sign" "$border_mode" "$ansi_sequence")
        [[ $reset_color_suffix == "=color" ]] && reset_color_suffix=$ansi_sequence
        printf "${ansi_sequence}%s${reset_color_suffix}\n" "$indented_text"
    else
        indented_text=$(wrap_text "$text" "$max_width" "$first_indent" "$extra_indent" "$align" "$force_break_sign" "$border_mode" false)
        echo -e "${indented_text}"
    fi

    [[ "$border_mode" == "full" ]] && add_border "$ansi_sequence"
}

eline() {
    local max_width="$1"
    local border=${2:-$BORDER_TOP}
    local border_left=${3:-$BORDER_TOP_LEFT}
    local border_right=${4:-$BORDER_TOP_RIGHT}
    printf "%s%s%s\n" "$border_left" "$(printf "%-${max_width}s" "$border" | tr ' ' "$border")" "$border_right"
}

extract_border_parts() {
    BORDER_TOP_LEFT=${BORDER:0:1}
    BORDER_TOP=${BORDER:1:1}
    BORDER_TOP_RIGHT=${BORDER:2:1}
    BORDER_LEFT=${BORDER:3:1}
    BORDER_RIGHT=${BORDER:4:1}
    BORDER_BOTTOM_LEFT=${BORDER:5:1}
    BORDER_BOTTOM=${BORDER:6:1}
    BORDER_BOTTOM_RIGHT=${BORDER:7:1}
}
extract_border_parts

etext_default() {
    local text=$1
    local color_name=${2:-white}
    local style_name=${3:-normal}
    local require_verbose=${4:-false}
    local extra_indent=${5:-2}
    local align=${6:-"left"}
    local border_mode=${7:-"integrated"}
    local force_break_sign=${8}
    local max_width=${9:-$TERMINAL_WIDTH}
    local reset_color_suffix=${10:-$RESET_COLOR}

    etext_optionadv "$color_name" "$style_name" "$text" "$require_verbose" \
        "$extra_indent" "$align" "$border_mode" "$max_width" "$force_break_sign" "$reset_color_suffix"
}

esuccess() { etext_default "  ✔ $1" green; }
ecomplete() { etext_optionadv green bold "  ➤ $1" false 6; }
esuccesshidden() { etext_default "  ✔ $1" cyan bold true; }
einfo() { etext_default "  ⓘ  $1" "${2:-cyan}"; }
einfohidden() { etext_default "  ⓘ  $1" "${2:-cyan}" normal true; }
edebug() { [[ "$VERBOSE" == "true" ]] && etext_optionadv "${2:-bgblue}" normal " | - $1" true 6 "left" "none" "$TERMINAL_WIDTH" "" "=color"; }
eerror() { etext_optionadv red bold "  ✖ $1" false; [[ -n "$ADD_ERROR_INFO" ]] && ewarning "$ADD_ERROR_INFO"; }
ewarning() { etext_default "   ⚠️ $1" yellow bold false 8; }
eaction() { etext_optionadv yellow bold "   →️ $1" false 8; }

eheader() {
    local text=$1
    local color=${2:-bblue}
    local border_mode=${3:-"full"}
    local require_verbose=${4:-false}
    local max_width=${5:-$TERMINAL_WIDTH}

    if [[ -n "$text" ]]; then
        etext_optionadv "$color" bold "$text" "$require_verbose" 5 "center" "full" "$max_width"
    fi
}

eheaderhidden() {
    eheader "$1"
}

niceprompt() {
    local formatted_prompt
    formatted_prompt=$(etext_optionadv byellow normal "  ➤ $1" false)
    read -p "$(echo -e "${formatted_prompt} ")" response
    echo "$response"
}

presskey() {
    formatted_prompt=$(etext_optionadv yellow normal "  ➟ Press any key to continue..." false)
    read -p "$(echo -e "${formatted_prompt} ")" response
    echo "$response"
}

equestion() {
    local formatted_prompt
    formatted_prompt=$(etext_optionadv byellow normal "  ➤ $1" false)
    echo "$formatted_prompt"
}

edebugvar() { etext_optionadv "${2:-bgblue}" normal " |   ├─  $1" true 6 "left" "none" "$TERMINAL_WIDTH" "" "=color"; }
edebugstart() {
    local color=${2:-bgblue}
    etext_optionadv "$color" bold "" true 6 "left" "none" "$TERMINAL_WIDTH" "" "=color"
    etext_optionadv "$color" bold " ⚙ ️$1" true 6 "left" "none" "$TERMINAL_WIDTH" "" "=color"
}
edebugclose() { etext_optionadv "${2:-bgblue}" normal " ⚙ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  >" true; }

align_text() {
    local text="$1"
    local max_width="$2"
    local align=${3:-"left"}
    local trim=${4:-false}

    [[ "$trim" == true ]] && text="$(echo -n "$text" | sed 's/^ *//;s/ *$//')"
    local text_length=${#text}

    if ((text_length >= max_width)); then
        echo "$text"
    elif [[ "$align" == "left" ]]; then
        printf "%s%*s" "$text" "$((max_width - text_length))" ""
    elif [[ "$align" == "right" ]]; then
        printf "%*s%s" "$((max_width - text_length))" "" "$text"
    elif [[ "$align" == "center" ]]; then
        local padding=$(((max_width - text_length) / 2))
        printf "%*s%s%*s" "$padding" "" "$text" "$((padding + (max_width - text_length) % 2))" ""
    else
        eerror "Invalid align value: $align. Must be 'left', 'right', or 'center'."
    fi
}

### [CSSH:UX:BORDER:START] ###
BORDER_STATE_LEFT=""
BORDER_STATE_RIGHT=""
BORDER_STATE_DIVIDER="~~~"
BORDER_INDENT="  "

add_border() {
    local border_ansi_sequence="$1"
    local encoded_sequence=$(encode_ansi_sequence "$ansi_sequence")
    BORDER_STATE_LEFT="${BORDER_STATE_LEFT}${BORDER_STATE_DIVIDER}${encoded_sequence}"
    BORDER_STATE_RIGHT="${encoded_sequence}${BORDER_STATE_DIVIDER}${BORDER_STATE_RIGHT}"
    edebug "Add border. $(printf "Ansi: \`%q\` \nCurrent count = %i \nState: %q | %q" "$border_ansi_sequence" $(echo "$BORDER_STATE_RIGHT" | grep -o "$BORDER_STATE_DIVIDER" | wc -l) "$BORDER_STATE_LEFT" "$BORDER_STATE_RIGHT")"
}

remove_border() {
    BORDER_STATE_LEFT="${BORDER_STATE_LEFT%${BORDER_STATE_DIVIDER}*}"
    BORDER_STATE_RIGHT="${BORDER_STATE_RIGHT#*${BORDER_STATE_DIVIDER}}"
    edebug "Borders removed, current state: $BORDER_STATE_LEFT | $BORDER_STATE_RIGHT"
}

get_current_left_border() {
    local result=""
    local IFS="$BORDER_STATE_DIVIDER"
    read -r -a borders <<< "$BORDER_STATE_LEFT"
    for encoded_border in "${borders[@]:1}"; do
        result+="$(decode_ansi_sequence "$encoded_border")${BORDER_LEFT}${BORDER_INDENT}"
    done
    echo -e "$result"
}

get_current_right_border() {
    local left_border=$(get_current_left_border)
    local result=""
    local lines=()

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        lines+=("$line")
    done <<< "$(echo -e "$left_border")"

    if [[ ${#lines[@]} -gt 0 ]]; then
        for ((i=${#lines[@]}-1; i>=0; i--)); do
            result+="${lines[i]}${BORDER_INDENT}${BORDER_RIGHT}\n"
        done
    fi
    echo -e "$result"
}
### [CSSH:UX:BORDER:END] ###

## [CSSH:UX:END] ##

## [CSSH:DEBUG:START] ##
printVars() {
    afterVars=($(compgen -v))
    for var in "${afterVars[@]}"; do
        if [[ ! " ${beforeVars[*]} " =~ $var ]]; then
            value="${!var}"
            value="${value//\\/\\\\}"
            value="${value//\"/\\\"}"
            edebugvar "$var: \"${value}\""
        fi
    done
    edebug "└── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  >"
}

if [[ "$VERBOSE" == "true" ]]; then
    edebugstart "Debugging Information"
    edebug "Script: $0"
    edebug "Current directory: $(pwd)"
    edebug "Number of Arguments: $#"
    edebug "Arguments: ${*}"
    edebug "Shell: $SHELL"
    edebug "Bash Version: $BASH_VERSION"
    edebug "Terminal: $TERM"
    edebug "ℹ️Variables"
    printVars
    edebugclose ""
fi
## [CSSH:DEBUG:END] ##

# [CSSH:0.1:END] #

show_menu() {
    eheader "choinek/repository-scripts downloader"
    einfo "[x] means the directory already exists" blue
    local index=1
    for dir in $(echo "$SCRIPT_GROUPS" | jq -r '.[].name'); do
        if [[ -d "$dir" ]]; then
            esuccess "$index) [x] $dir"
        else
            einfo "$index) [ ] $dir"
        fi
        ((index++))
    done
}

process_selection() {
    local selected_dir="$1"
    local dir_data=$(echo "$SCRIPT_GROUPS" | jq -r ".[] | select(.name == \"$selected_dir\")")

    local name=$(echo "$dir_data" | jq -r '.name')
    local description=$(echo "$dir_data" | jq -r '.description')

    eheader "Directory: $name"
    einfo "Description: $description"
    einfo "Files:"
    echo "$dir_data" | jq -r '.files[]' | while read -r file; do
        echo "  - $file"
    done
}

einfo "Webpage and informations: https://choinek.github.io/repository-scripts/"
eaction "Fetching script groups list from $INDEX_URL..."
RAW_JSON=$(curl -sL "$INDEX_URL")

if [[ $? -ne 0 || -z "$RAW_JSON" ]]; then
    eerror "Failed to fetch script groups list."
    exit 1
fi

CLEANED_JSON=$(echo "$RAW_JSON" | tr -d '\000-\031')
if ! echo "$CLEANED_JSON" | jq empty >/dev/null 2>&1; then
    eerror "Invalid JSON fetched from $INDEX_URL."
    exit 1
fi

SCRIPT_GROUPS="$CLEANED_JSON"
einfohidden "Fetched $(echo "$SCRIPT_GROUPS" | jq length) directories."

while true; do
    show_menu
    choice=$(niceprompt "Choose a directory (or press Enter to exit):")
    [[ -z "$choice" ]] && { esuccess "Exiting."; break; }

    selected_dir=$(echo "$SCRIPT_GROUPS" | jq -r ".[$((choice - 1))].name")
    if [[ -n "$selected_dir" ]]; then
        process_selection "$selected_dir"
        presskey
    else
        eerror "Invalid selection."
        presskey
    fi
done
