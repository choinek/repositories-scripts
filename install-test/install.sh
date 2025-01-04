#!/bin/bash
VERBOSE=true
TERMINAL_COLOR=false
TERMINAL_WIDTH=$(stty size 2>/dev/null | awk '{print $2}' || echo 100)
TERMINAL_WIDTH=$((TERMINAL_WIDTH - 2)) # Subtract 2 for base padding
BORDER="╒═╕││╘═╛"
ADD_ERROR_INFO="Check $WEBPAGE_URL for help or updates."
if [ -z "$BASH_SOURCE" ]; then
    SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

LIB_DIR="$SCRIPT_DIR/lib"

load_library() {
    local lib_name="$1"
    local lib_path="$LIB_DIR/$lib_name"

    if [ -f "$lib_path" ]; then
        . "$lib_path"
        return 0
    else
        echo "Error: Cannot find library: $lib_path"
        return 1
    fi
}

for lib in "cssh-os.sh" "cssh-ui.sh"; do # "cssh-utils.sh"
    if ! load_library "$lib"; then
        echo "Fatal: Failed to load required library: $lib"
        exit 1
    fi
done
einfohidden "Test DebASASDASDAug Message"
echo "asd"
exit
eheader "Test Header"
einfo "Test Info Message"
esuccess "Test Success Message"
eerror "Test Error Message"
