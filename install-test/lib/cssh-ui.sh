## [CSSH:UX:START] ##
TERMINAL_COLOR=${TERMINAL_COLOR:-true}
TERMINAL_WIDTH=${TERM_WIDTH:-$(tput cols 2>/dev/null || echo 80)}
TERM_FEATURES=${TERM_FEATURES:-"basic"}
USE_ASCII=${USE_ASCII:-false}


VERBOSE=${VERBOSE:-false}
echo "VERBOSE $VERBOSE"
# Handle verbose flag if passed
while getopts "v" opt; do
    case $opt in
        v) VERBOSE=true ;;
    esac
done

echo "VERBOSE $VERBOSE"
if [[ "$USE_ASCII" == true ]]; then
    SYM_SUCCESS="+"
    SYM_INFO="i"
    SYM_WARNING="!"
    SYM_ERROR="x"
    SYM_ARROW="->"
    SYM_PROMPT=">"
    SYM_BULLET="-"
else
    SYM_SUCCESS="✔"
    SYM_INFO="ⓘ"
    SYM_WARNING="⚠️"
    SYM_ERROR="✖"
    SYM_ARROW="→️"
    SYM_PROMPT="➤"
    SYM_BULLET="•"
fi

case "$TERM_FEATURES" in
    "full"|"most")
        [[ "$USE_ASCII" == false ]] && BORDER="╒═╕││╘═╛" || BORDER="+--+||+--+"
        ;;
    *)
        BORDER="+--+||+--+"
        ;;
esac

if [[ "$TERM_FEATURES" == "none" || "$TERM" == "dumb" || "$TERM_HAS_COLORS" -lt 8 ]]; then
    TERMINAL_COLOR=false
    RESET_COLOR=""
else
    RESET_COLOR="\033[0m"
fi

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

BORDER_STATE_LEFT=""
BORDER_STATE_RIGHT=""
BORDER_STATE_DIVIDER="~~~"
BORDER_INDENT="  "

align_text() {
    local text="$1"
    local max_width="$2"
    local align=${3:-"left"}
    local trim=${4:-false}

    if [[ "$trim" == true ]]; then
        text="$(echo -n "$text" | sed 's/^ *//;s/ *$//')"
    fi

    local text_length
    # Remove ANSI sequences when calculating length
    text_length=$(echo -n "$text" | sed 's/\x1b\[[0-9;]*m//g' | wc -c)

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
    fi
}

# Draw line helper
eline() {
    local max_width="$1"
    local border=${2:-$BORDER_TOP}
    local border_left=${3:-$BORDER_TOP_LEFT}
    local border_right=${4:-$BORDER_TOP_RIGHT}
    printf "%s%s%s\n" "$border_left" "$(printf "%-${max_width}s" "$border" | tr ' ' "$border")" "$border_right"
}

# Main text formatting function
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

    # Skip if verbose is required but not enabled
    echo "ANOTHRE $VERBOSE"
    [[ "$require_verbose" == "true" && "$VERBOSE" != "true" ]] && return

echo "WTF?"
    # Color and style codes for supported terminals
    local color_code=""
    local style_code=""

    if [[ $TERMINAL_COLOR == true ]]; then
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
        esac

        case $style_name in
            bold) style_code="1" ;;
            normal) style_code="0" ;;
        esac
    fi

    # Text wrapping function
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

        if [[ "$border_mode" == "full" ]]; then
            wrapped_text+=$(printf "%s\n" "$(eline "$max_width" "${BORDER_TOP}" "${BORDER_TOP_LEFT}" "${BORDER_TOP_RIGHT}")")
        fi

        local line_width=$((max_width - ${#indent} - ${#left_border} - ${#right_border}))

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

            $first_line && first_line=false && indent=$(printf "%${extra_indent}s")
            line=$(align_text "${indent}$line" "$line_width" "$align")
            wrapped_text+="${left_border}${line}${right_border}\n"
        done

        [[ "$border_mode" == "full" ]] && wrapped_text+=$(printf "%s\n" "$(eline "$max_width" "${BORDER_BOTTOM}" "${BORDER_BOTTOM_LEFT}" "${BORDER_BOTTOM_RIGHT}")")

        echo -e "$wrapped_text"
    }

    # Apply formatting and output
    local ansi_sequence=""
    [[ $TERMINAL_COLOR == true && -n $color_code && -n $style_code ]] && ansi_sequence="\033[${style_code};${color_code}m"

    local formatted_text=$(wrap_text "$text" "$max_width" "$first_indent" "$extra_indent" "$align" "$force_break_sign" "$border_mode" "$ansi_sequence")

    if [[ -n $ansi_sequence ]]; then
        [[ $reset_color_suffix == "=color" ]] && reset_color_suffix=$ansi_sequence
        printf "${ansi_sequence}%s${reset_color_suffix}\n" "$formatted_text"
    else
        echo -e "$formatted_text"
    fi
}

# Simplified text output function
etext_default() {
    etext_optionadv "${@}"
}

# Common message types using symbols
esuccess() { etext_default "  ${SYMBOLS[SUCCESS]} $1" green; }
ecomplete() { etext_optionadv green bold "  ${SYMBOLS[PROMPT]} $1" false 6; }
esuccesshidden() { etext_default "  ${SYMBOLS[SUCCESS]} $1" cyan bold true; }
einfo() { etext_default "  ${SYMBOLS[INFO]}  $1" "${2:-cyan}"; }
einfohidden() { etext_default "  ${SYMBOLS[INFO]}  $1" "${2:-cyan}" normal true; }
ewarning() { etext_default "   ${SYMBOLS[WARNING]} $1" yellow bold false 8; }
eerror() { etext_optionadv red bold "  ${SYMBOLS[ERROR]} $1" false; }
eaction() { etext_optionadv yellow bold "   ${SYMBOLS[ARROW]} $1" false 8; }

# Header functions
eheader() {
    local text=$1
    local color=${2:-bblue}
    local border_mode=${3:-"full"}
    local require_verbose=${4:-false}
    local max_width=${5:-$TERMINAL_WIDTH}
    [[ -n "$text" ]] && etext_optionadv "$color" bold "$text" "$require_verbose" 5 "center" "full" "$max_width"
}

eheaderhidden() { eheader "$1" "$2" "$3" true; }

# Interactive prompts
niceprompt() {
    local formatted_prompt=$(etext_optionadv byellow normal "  ${SYMBOLS[PROMPT]} $1" false)
    read -p "$(echo -e "${formatted_prompt} ")" response
    echo "$response"
}

presskey() {
    local formatted_prompt=$(etext_optionadv yellow normal "  ${SYMBOLS[ARROW]} Press any key to continue..." false)
    read -p "$(echo -e "${formatted_prompt} ")" response
    echo "$response"
}

equestion() {
    local formatted_prompt=$(etext_optionadv byellow normal "  ${SYMBOLS[PROMPT]} $1" false)
    echo "$formatted_prompt"
}

## [CSSH:UX:END] ##
