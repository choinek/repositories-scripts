#!/bin/bash
#### Old script, deprecated, I committed it out of sentiment. :)
#### USE ./mac-free .sh instead #!/bin/bash
#echo "Deprecated, if you want to use it replace first 4 lines with #!/bin/bash"
#
UNIT="k"
DELAY=1
COUNT=1
SHOW_TOTALS=0

# <ChoinekColors>
NO_COLOR=0
RANDOM_COLORS=0
generate_random_color() {
   local style=$((RANDOM % 2 + 1))       # bold or no bold :)
   local foreground=$((RANDOM % 8 + 30)) # 30-37
   echo -e "\\033[${style};${foreground}m"
}

HEADER_COLOR='\033[1;37m'
MEM_COLOR='\033[0;36m'
SWAP_COLOR='\033[0;32m'
TOTAL_COLOR='\033[0;31m'
RESET='\033[0m'
apply_color() {
   if [ $NO_COLOR -eq 1 ]; then
      HEADER_COLOR=''
      MEM_COLOR=''
      SWAP_COLOR=''
      TOTAL_COLOR=''
      RESET=''
   elif [ $RANDOM_COLORS -eq 1 ]; then
      HEADER_COLOR=$(generate_random_color)
      MEM_COLOR=$(generate_random_color)
      SWAP_COLOR=$(generate_random_color)
      TOTAL_COLOR=$(generate_random_color)
   fi
}
# </ChoinekColors>

convert_unit() {
   local bytes=$1
   case $UNIT in
   k) echo "$((bytes / 1024))" ;;
   m) echo "$((bytes / 1024 / 1024))" ;;
   g) echo "$((bytes / 1024 / 1024 / 1024))" ;;
   esac
}

get_max_length() {
   local longest=0
   for value in "$@"; do
      length=${#value}
      if ((length > longest)); then
         longest=$length
      fi
   done
   echo $longest
}

display_memory() {
   PAGE_SIZE=$(vm_stat | grep "page size of" | awk '{print $8}')
   FREE=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
   ACTIVE=$(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
   INACTIVE=$(vm_stat | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
   WIRED=$(vm_stat | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')

   TOTAL_BYTES=$(sysctl -n hw.memsize)

   FREE_BYTES=$((FREE * PAGE_SIZE))
   ACTIVE_BYTES=$((ACTIVE * PAGE_SIZE))
   INACTIVE_BYTES=$((INACTIVE * PAGE_SIZE))

   WIRED_BYTES=$((WIRED * PAGE_SIZE))
   USED_BYTES=$((ACTIVE_BYTES + WIRED_BYTES))
   BUFF_CACHE_BYTES=$((INACTIVE_BYTES))
   AVAILABLE_BYTES=$((FREE_BYTES + BUFF_CACHE_BYTES))

#   SWAP_TOTAL=$(sysctl -n vm.swapusage | awk '{print $3}' | sed 's/M//')
#   SWAP_USED=$(sysctl -n vm.swapusage | awk '{print $7}' | sed 's/M//')
#   SWAP_FREE=$(sysctl -n vm.swapusage | awk '{print $10}' | sed 's/M//')

#   max_mem_len=$(get_max_length "$TOTAL_BYTES" "$USED_BYTES" "$FREE_BYTES" "$BUFF_CACHE_BYTES" "$AVAILABLE_BYTES")
#   max_swap_len=$(get_max_length "$SWAP_TOTAL" "$SWAP_USED" "$SWAP_FREE")

   # @todo calculate strpads
   echo -e "${HEADER_COLOR}         total$(printf '%*s' $((max_mem_len - 4))) used$(printf '%*s' $((max_mem_len - 4))) free$(printf '%*s' $((max_mem_len - 4))) shared       buff/cache   available${RESET}"
   printf "${MEM_COLOR}Mem:${RESET}     %-12s %-12s %-12s %-12s %-12s %-12s\n" \
      "$(convert_unit "$TOTAL_BYTES")" "$(convert_unit $USED_BYTES)" \
      "$(convert_unit $FREE_BYTES)" "0" "$(convert_unit $BUFF_CACHE_BYTES)" \
      "$(convert_unit $AVAILABLE_BYTES)"
   printf "${SWAP_COLOR}Swap:${RESET}    %-12s %-12s %-12s\n" \
      "$(convert_unit "$SWAP_TOTAL")" "$(convert_unit "$SWAP_USED")" \
      "$(convert_unit "$SWAP_FREE")"

   if [ $SHOW_TOTALS -eq 1 ]; then
      TOTAL_USED=$((USED_BYTES + BUFF_CACHE_BYTES))
      TOTAL_FREE=$((FREE_BYTES))

      TOTAL_SWAP_USED=$((SWAP_USED))
      TOTAL_SWAP_FREE=$((SWAP_FREE))

      printf "${TOTAL_COLOR}Total:${RESET}   %-12s %-12s %-12s %-12s %-12s %-12s\n" \
         "$(convert_unit $TOTAL_BYTES)" "$(convert_unit $TOTAL_USED)" \
         "$(convert_unit $TOTAL_FREE)" "0" "$(convert_unit $BUFF_CACHE_BYTES)" \
         "$(convert_unit $AVAILABLE_BYTES)"
   fi
}

show_help() {
   echo "Usage: free [options]"
   echo ""
   echo "Options:"
   echo "  -c count      Display the result count times. Requires -s option. "
   echo "  -g            Display the amount of memory in gigabytes."
   echo "  -k            Display the amount of memory in kilobytes (default)."
   echo "  -m            Display the amount of memory in megabytes."
   echo "  -h            Alias for -m. :P"
   echo "  -s delay      Continuously display the result every  'delay' seconds."
   echo "  -t            Display a line showing column totals."
   echo "  -V            Display version information. "
   echo "  --no-color    Disable color output."
   echo "  --help        Show this help message. "
}

while [[ $# -gt 0 ]]; do
   case $1 in
   -c)
      COUNT=$2
      shift
      ;;
   -g) UNIT="g" ;;
   -k) UNIT="k" ;;
   -m | -h) UNIT="m" ;;
   -s)
      DELAY=$2
      shift
      ;;
   -t) SHOW_TOTALS=1 ;;
   -V)
      echo "free for macOS"
      echo "v25-01-07"
      echo "~~ choinek"
      exit 0
      ;;
   --no-color) NO_COLOR=1 ;;
   --random-color) RANDOM_COLORS=1 ;;
   --help)
      show_help
      exit 0
      ;;
   *)
      echo "Unknown option: $1. Use --help for usage information."
      exit 1
      ;;
   esac
   shift
done

apply_color

for ((i = 1; i <= COUNT; i++)); do
   display_memory
   if [ $i -lt $COUNT ]; then
      sleep $DELAY
   fi
done
