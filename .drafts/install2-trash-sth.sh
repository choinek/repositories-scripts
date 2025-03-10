### BASH TRASH - TO CLEANUP ###

#!/bin/bash

printf "\n\n\n\n\n";
beforeVars=($(compgen -v))
beforeVars+=("afterVars" "opt" "PIPESTATUS" "FUNCNAME" "SED_INPLACE")
#INDEX_URL="https://choinek.github.io/scripts/index.json"
INDEX_URL="https://raw.githubusercontent.com/choinek/scripts/main/index.json"
WEBPAGE_URL="https://choinek.github.io/scripts/"
# [CSSH:0.1:START] #
# [CSSH:DESCRIPTION:START] #
# CSSH = Choinek's Standard Shell Handler :) #
# https://github.com/choinek/scripts/tree/main/choinek-shell-scripts #
# Version: 0.1.0 #
# [CSSH:DESCRIPTION:END] #
## [CSSH:OPTS:START] ##
VERBOSE=false
TERMINAL_COLOR=true
TERMINAL_WIDTH=$(stty size 2>/dev/null | awk '{print $2}' || echo 100)
TERMINAL_WIDTH=$((TERMINAL_WIDTH - 2)) # Subtract 2 for base padding
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
            echo ""
            echo "Options:"
            echo "  -v         Enable verbose mode to display detailed output."
            exit 1
            ;;
        esac
        ;;
    *)
        echo "Invalid option: -$OPTARG" >&2
        echo "Usage: $0 [-v]"
        echo ""
        echo "Options:"
        echo "  -v         Enable verbose mode to display detailed output."
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

#log_to_file() {
#    #local log_file="$1"
#    local log_file="log.txt"
#
#    if [[ -z "$log_file" ]]; then
#        echo "Usage: log_to_file <log_file> <message or array elements...>"
#        return 1
#    fi
#
#    echo "[$(date '+%Y-%m-%d %H:%M:%S')] => " >> "$log_file"
##
##    for arg in "$@"; do
##        echo "- $arg" >> "$log_file"
##    done
##
##    echo "" >> "$log_file"
#
##    for var_name in "$@"; do
##        local value
##        value=$(eval "echo \$$var_name")
##
##        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $var_name=$value" >> "$log_file"
##    done
#
#echo "$@"
#   for var_name in "$@"; do
#        local value="${!var_name}"
#        if echo -n "$value" | od -An -t x1 | grep -qE '\b(0[0-9a-f]|7f)\b'; then
#            local encoded_value
#            encoded_value=$(echo -n "$value" | base64)
#            echo "[$(date '+%Y-%m-%d %H:%M:%S')] $var_name=ENCODED:$encoded_value" >> "$log_file"
#        else
#            echo "[$(date '+%Y-%m-%d %H:%M:%S')] $var_name=$value" >> "$log_file"
#        fi
#    done
#}

log_to_file() {
    local log_file="log.txt"

    # Join all remaining arguments into a single string
    local log_row
    log_row=$(printf "%s " "$@")

    # Write the aggregated row to the log file
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $log_row" >> "$log_file"
}


## [CSSH:UTILS:END] ##

## [CSSH:UX:START] ##

RESET_COLOR="\033[0m"

etext_optionadv() {
    local color_name=${1}
    local style_name=${2}
    local text=${3}
    local require_verbose=${4}

    if [[ $require_verbose == "true" && $VERBOSE == "false" ]]; then
        return
    fi

    local extra_indent=${5:-6}
    local align=${6:-"left"}
    local border_mode=${7:-"integrated"}
    # integrated = indents inside
    # full = indents inside and full border around
    # separated = indents outside
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
        random_hash=$(echo $RANDOM | md5 | awk '{print $1}')

        #log_to_file "🍎 wrap_text" $random_hash $input "$max_width" "$first_indent" "$extra_indent" "$align" "$force_break_sign" "$border_mode" "$ansi_sequence"

        local left_border="${BORDER_LEFT}"
        local right_border="${BORDER_RIGHT}"
        if [[ -z "$border_mode" || "$border_mode" == "none" ]]; then
            left_border=""
            right_border=""
        fi
        local indent=$(printf "%${first_indent}s")
        local wrapped_text=""
        local first_line=true
        border_left_state=$(printf "%s" "$(get_current_left_border)")
        border_right_state=$(printf "%s" "$(get_current_right_border)")
        left_border=$(printf "%s%s" "$(get_current_left_border)" "$left_border")
        right_border=$(printf "%s%s" "$right_border" "$(get_current_right_border)")

        #log_to_file "🍌wrap_text::border_state" "$random_hash" "LeftBorder: $left_border" "RightBordr: $right_border" "LeftState: $border_left_state" "RightState: $border_right_state"

        clean_left_border=$(echo -e "$left_border" | LC_ALL=C sed 's/\x1b\[[0-9;]*m//g')
        clean_right_border=$(echo -e "$right_border" | LC_ALL=C sed 's/\x1b\[[0-9;]*m//g')

    #    log_to_file "clean_borders" $((${#clean_left_border} + ${#clean_right_border}))
        local border_size=$((${#clean_left_border} + ${#clean_right_border}))

        max_width=$((max_width - border_size))

        #local border_size=$((${#left_border} + ${#right_border}))

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
                    if [[ -z "$line" ]]; then
                        line=${input:0:$line_width}
                    fi

                    input=${input:${#line}}
                    # shellcheck disable=SC2001 # don't know how to workaround it without sed
                    input=$(echo "$input" | sed 's/^[[:space:]]*//')
                    #input=${input##*[[:space:]]}
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

            #log_to_file "🥨 wrap_text::finalfull" "$random_hash" "$wrapped_text" "$border_left_state" "$border_right_state"

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
        if [[ $reset_color_suffix == "=color" ]]; then
            reset_color_suffix=$ansi_sequence
        fi

        printf "${ansi_sequence}%s${reset_color_suffix}\n" "$indented_text"
    else
        indented_text=$(wrap_text "$text" "$max_width" "$first_indent" "$extra_indent" "$align" "$force_break_sign" "$border_mode" false)
        echo -e "${indented_text}"
    fi

    if [[ "$border_mode" == "full" ]]; then
        add_border "$ansi_sequence"
    fi
}

##eline() {
#    local max_width="$1"
#    local fill_char=${2:-$BORDER_TOP}
#    local left_char=${3:-$BORDER_TOP_LEFT}
#    local right_char=${4:-$BORDER_TOP_RIGHT}
#
#    printf "%s" "$left_char"
#    for ((i = 0; i < max_width; i++)); do
#        printf "%s" "$fill_char"
#    done
#    printf "%s\n" "$right_char"
#}
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


esuccess() {
    etext_default "  ✔ $1" green
}

ecomplete() {
    etext_optionadv green bold "  ➤ $1" false 6
}

esuccesshidden() {
    etext_default "  ✔ $1" cyan bold true
}

einfo() {
    etext_default "  ⓘ  $1" "${2:-cyan}"
}

einfohidden() {
    etext_default "  ⓘ  $1" "${2:-cyan}" normal true
}

edebug() {
    local color=${2:-bgblue}
    etext_optionadv "$color" normal " | - $1" true 6 "left" "none" "$TERMINAL_WIDTH" "" "=color"
}

edebugvar() {
    local color=${2:-bgblue}
    etext_optionadv "$color" normal " |   ├─  $1" true 6 "left" "none" "$TERMINAL_WIDTH" "" "=color"
}

edebugstart() {
    local color=${2:-bgblue}
    etext_optionadv "$color" bold "" true 6 "left" "none" "$TERMINAL_WIDTH" "" "=color"
    etext_optionadv "$color" bold " ⚙ ️$1" true 6 "left" "none" "$TERMINAL_WIDTH" "" "=color"
}

edebugclose() {
    local color=${2:-bgblue}
    etext_optionadv "$color" normal " ⚙ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  >" true
}

align_text() {
    local text="$1"
    local max_width="$2"
    local align=${3:-"left"}
    local trim=${4:-false}

    if [[ "$trim" == true ]]; then
        text="$(echo -n "$text" | sed 's/^ *//;s/ *$//')"
    fi

    local text_length=${#text}

    if ((text_length >= max_width)); then
        echo "$text"
    elif [[ "$align" == "left" ]]; then
        local padding=$((max_width - text_length))
        printf "%s%*s" "$text" "$padding" ""
    elif [[ "$align" == "right" ]]; then
        printf "%*s%s" "$((max_width - text_length))" "" "$text"
    elif [[ "$align" == "center" ]]; then
        local padding=$(((max_width - text_length) / 2))
        local left_padding=$padding
        local right_padding=$((padding + (max_width - text_length) % 2))
        printf "%*s%s%*s" "$left_padding" "" "$text" "$right_padding" ""
    else
        eerror "Invalid align value: $align. Must be 'left', 'right', or 'center'."
    fi
}

draw_line() {
    local char=$1
    local max_width=$2
    printf "%s" "$char"
    for ((i = 0; i < max_width; i++)); do
        printf "═"
    done
    printf "%s\\n" "$char"
}

eheader() {
    local text=$1
    local color=${2:-bblue}
    local border_mode=${3:-"full"}
    local require_verbose=${4:-false}
    local max_width=${5:-$TERMINAL_WIDTH}

#    if [[ $border_mode == false ]]; then
#        line="$(eline "$max_width")"
#        etext_optionadv bblue normal "$line" "$require_verbose" 0 "center" "none" "$max_width"
#    fi

    if [[ -n "$text" ]]; then
        etext_optionadv "$color" bold "$text" "$require_verbose" 5 "center" "full" "$max_width"
    fi

#    if [[ $border_mode == false ]]; then
#        line="$(eline "$max_width" "$BORDER_BOTTOM" "$BORDER_BOTTOM_LEFT" "$BORDER_BOTTOM_RIGHT")"
#        etext_optionadv bblue normal "$line" "$require_verbose" 0 "center" "none" "$max_width"
#    fi
}

eheaderhidden() {
    local text=$1
#    local max_width=$(2:-"$TERMINAL_WIDTH")
#    local border_mode=${3:-false}
    eheader "$1" #"$2" "$3" true
}

ewarning() {
    etext_default "   ⚠️ $1" yellow bold false 8
}

eaction() {
    etext_optionadv yellow bold "   →️ $1" false 8
}

eerror() {
    etext_optionadv red bold "  ✖ $1" false
    if [[ -n "$ADD_ERROR_INFO" ]]; then
        ewarning "$ADD_ERROR_INFO"
    fi
}

eoption() {
    text=$1
    left_width=${2:-5}
    style=${3:-bold}
    before="${text%%)*}"
    after="${text#*)}"
    indent=$((left_width + 8))
    before=$(printf "%${left_width}s" "$before")
    if [[ $TERMINAL_COLOR == true ]]; then
        etext_optionadv white "$style" "  ➤ \033[0;93m$before)\033[0;97m$after" false $indent

    else
        etext_optionadv white "$style" "  ➤ $before)$after" false $indent
    fi
}

eoptionadv() {
    eoption "$1" "$2" normal
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

### [CSSH:UX:BORDER:START] ###

BORDER_STATE_LEFT=""
BORDER_STATE_RIGHT=""
BORDER_STATE_DIVIDER="~~~"
BORDER_INDENT="  "

add_border() {
    local border_ansi_sequence="$1"
    local encoded_sequence=$(encode_ansi_sequence "$ansi_sequence")

    #log_to_file "🍏 add_border" "$border_ansi_sequence" "$encoded_sequence"
    BORDER_STATE_LEFT="${BORDER_STATE_LEFT}${BORDER_STATE_DIVIDER}${encoded_sequence}"
    BORDER_STATE_RIGHT="${encoded_sequence}${BORDER_STATE_DIVIDER}${BORDER_STATE_RIGHT}"
    local escapedState=$(printf "Ansi: \`%q\` \nCurrent count = %i \nState: %q | %q" "$border_ansi_sequence" $(echo "$BORDER_STATE_RIGHT" | grep -o "$BORDER_STATE_DIVIDER" | wc -l) "$BORDER_STATE_LEFT" "$BORDER_STATE_RIGHT")
    edebug "\nAdd border. $escapedState"
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
        local decoded_border=$(decode_ansi_sequence "$encoded_border")
        result+="${decoded_border}${BORDER_LEFT}${BORDER_INDENT}"
    done
    echo -e "$result"
}

get_current_right_border() {
    local left_border
    left_border=$(get_current_left_border)
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

## [CSSH:DEBUG:END] ##

# [CSSH:0.1:END] #

function show_menu {
    eheader "choinek/scripts downloader"
    eheader "Test: choinek/scripts downloader"
    einfo "[x] means the directory already exists" blue
    local index=1
    for dir in $(echo "$SCRIPT_GROUPS" | jq -r '.[].name'); do
        if [[ -d "$dir" ]]; then
            esuccess "$index) [x] $dir"
        else
            einfo "$index) [ ] $dir"
        fi
        index=$((index + 1))
    done
}

function process_selection {
    local selected_dir="$1"
    local dir_data=$(echo "$SCRIPT_GROUPS" | jq -r ".[] | select(.name == \"$selected_dir\")")

    local name=$(echo "$dir_data" | jq -r '.name')
    local description=$(echo "$dir_data" | jq -r '.description')

    eheader "Directory: $name"
    einfo "Description: $description"

    local files=$(echo "$dir_data" | jq -r '.files[]')
    einfo "Files:"
    for file in $files; do
        echo "  - $file"
    done
}

#eheader "choinek/scripts downloader"
einfo "Webpage and informations: https://choinek.github.io/scripts/"
INDEX_URL="https://choinek.github.io/scripts/index.json"
eaction "Fetching script groups list from $INDEX_URL..."
RAW_JSON=$(curl -sL "$INDEX_URL")
curlStatus=$?
if [ $curlStatus -ne 0 ]; then
    eerror "Failed to fetch script groups list."
    exit 1
fi

if [ -z "$RAW_JSON" ]; then
    eerror "Error: Empty response from $INDEX_URL."
    exit 1
fi
CLEANED_JSON=$(echo "$RAW_JSON" | tr -d '\000-\031')
if echo "$CLEANED_JSON" | jq empty >/dev/null 2>&1; then
    SCRIPT_GROUPS="$CLEANED_JSON"
else
    eerror "Invalid JSON fetched from $INDEX_URL."
    exit 1
fi
einfohidden "Fetched $(echo "$SCRIPT_GROUPS" | jq length) directories."

while true; do
    show_menu
    choice=$(niceprompt "Choose a directory (or press Enter to exit):")
    if [[ -z "$choice" ]]; then
        esuccess "Exiting."
        break
    fi

    selected_dir=$(echo "$SCRIPT_GROUPS" | jq -r ".[$((choice - 1))].name")

    if [[ -n "$selected_dir" ]]; then
        process_selection "$selected_dir"
        presskey
    else
        eerror "Invalid selection."
        presskey
    fi
done
