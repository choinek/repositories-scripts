## [CSSH:OS:START] ##
# Define supported OS types and set defaults
SUPPORTED_OSTYPES="linux-gnu darwin bsd msys cygwin"
TERMINAL_COLOR=true
USE_ASCII=false
PATH_SEP="/"
SED_INPLACE=()
DISTRO="unknown"
TERM_HAS_COLORS=0
TERM_IS_UTF8="ASCII"
TERM_WIDTH=80
PKG_MANAGER=""
TERM_FEATURES="basic"

# Function to detect terminal capabilities
detect_terminal() {
    case "$TERM" in
        xterm*|screen*|tmux*)  TERM_FEATURES="full" ;;
        rxvt*)                 TERM_FEATURES="most" ;;
        vt100|ansi)           TERM_FEATURES="basic" ;;
        dumb)                 TERM_FEATURES="none" ;;
        *)                    TERM_FEATURES="basic" ;;
    esac

    TERM_HAS_COLORS=$(tput colors 2>/dev/null || echo 0)
    [[ $TERM_HAS_COLORS -lt 8 ]] && TERMINAL_COLOR=false

    TERM_IS_UTF8=$(locale charmap 2>/dev/null)
    [[ "$TERM_IS_UTF8" != "UTF-8" ]] && USE_ASCII=true

    TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
}

detect_package_manager() {
    if command -v apt-get >/dev/null; then
        PKG_MANAGER="apt"
    elif command -v yum >/dev/null; then
        PKG_MANAGER="yum"
    elif command -v dnf >/dev/null; then
        PKG_MANAGER="dnf"
    elif command -v brew >/dev/null; then
        PKG_MANAGER="brew"
    elif command -v pacman >/dev/null; then
        PKG_MANAGER="pacman"
    fi
}

if [[ -z "$OSTYPE" ]]; then
    OSTYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
    echo "The OSTYPE environment variable is not set."
    echo "Detected OS type: $OSTYPE"
    echo "Supported values:"
    for ost in $SUPPORTED_OSTYPES; do
        echo "  - $ost"
    done
    read -p "Is this correct? If not, please select from the list above [Y/type]: " user_input
    if [[ "$user_input" != "Y" && "$user_input" != "y" ]]; then
        if [[ "$SUPPORTED_OSTYPES" == *"$user_input"* ]]; then
            OSTYPE="$user_input"
        else
            echo "Invalid OSTYPE: $user_input. Exiting."
            exit 1
        fi
    fi
fi

case "$OSTYPE" in
    *"linux-gnu"*)
        if [[ -f /etc/os-release ]]; then
            DISTRO=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
        fi
        SED_INPLACE=("sed" "-i")
        ;;
    *"darwin"*)
        SED_INPLACE=("sed" "-i" "")
        DISTRO="macos"
        ;;
    *"bsd"*)
        SED_INPLACE=("sed" "-i" "")
        DISTRO="bsd"
        ;;
    *"msys"*|*"cygwin"*)
        PATH_SEP="\\"
        SED_INPLACE=("sed" "-i")
        DISTRO="windows"
        ;;
    *)
        echo "Unsupported OS type: $OSTYPE"
        exit 1
        ;;
esac

realpath() {
    local path="$1"
    if [[ -d "$path" ]]; then
        cd "$path" && pwd
    else
        local dir
        dir=$(cd "$(dirname "$path")" && pwd)
        echo "${dir}${PATH_SEP}$(basename "$path")"
    fi
}

REQUIRED_COMMANDS="curl sed awk grep"
MISSING_COMMANDS=""

for cmd in $REQUIRED_COMMANDS; do
    if ! command -v "$cmd" >/dev/null; then
        MISSING_COMMANDS="$MISSING_COMMANDS $cmd"
    fi
done

if [[ -n "$MISSING_COMMANDS" ]]; then
    echo "Missing required commands:$MISSING_COMMANDS"
    echo "Please install them using your package manager ($PKG_MANAGER)"
    exit 1
fi

detect_terminal
detect_package_manager

if [[ "$DEBUG" == "true" ]]; then
    echo "OS Detection Results:"
    echo "OS Type: $OSTYPE"
    echo "Distribution: $DISTRO"
    echo "Package Manager: $PKG_MANAGER"
    echo "Terminal Features: $TERM_FEATURES"
    echo "Terminal Colors: $TERM_HAS_COLORS"
    echo "UTF-8 Support: $TERM_IS_UTF8"
    echo "Terminal Width: $TERM_WIDTH"
    echo "Using ASCII: $USE_ASCII"
fi
## [CSSH:OS:END] ##
