#!/bin/bash

UNIT="kibi"
DELAY=1
COUNT=1
SHOW_TOTALS=0
SHOW_LOW_HIGH=0
HUMAN=0
LINE=0
SI=0
NO_COLOR=0

HEADER_COLOR='\033[1;37m'
MEM_COLOR='\033[0;36m'
SWAP_COLOR='\033[0;32m'
TOTAL_COLOR='\033[0;34m'
RESET='\033[0m'

apply_color() {
  if [ $NO_COLOR -eq 1 ]; then
    HEADER_COLOR=''
    MEM_COLOR=''
    SWAP_COLOR=''
    TOTAL_COLOR=''
    RESET=''
  fi
}

convert_unit() {
  local bytes=$1
  case $UNIT in
    bytes) echo "$bytes" ;;
    kilo) echo "$((bytes / 1000))" ;;
    mega) echo "$((bytes / 1000 / 1000))" ;;
    giga) echo "$((bytes / 1000 / 1000 / 1000))" ;;
    tera) echo "$((bytes / 1000 / 1000 / 1000 / 1000))" ;;
    peta) echo "$((bytes / 1000 / 1000 / 1000 / 1000 / 1000))" ;;
    kibi) echo "$((bytes / 1024))" ;;
    mebi) echo "$((bytes / 1024 / 1024))" ;;
    gibi) echo "$((bytes / 1024 / 1024 / 1024))" ;;
    tebi) echo "$((bytes / 1024 / 1024 / 1024 / 1024))" ;;
    pebi) echo "$((bytes / 1024 / 1024 / 1024 / 1024 / 1024))" ;;
  esac
}

get_memory_info() {
  TOTAL_MEM=$(sysctl -n hw.memsize)
  PAGE_SIZE=$(vm_stat | grep "page size of" | awk '{print $8}')
  FREE_PAGES=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')
  WIRED_PAGES=$(vm_stat | grep "Pages wired down" | awk '{print $4}' | tr -d '.')
  ACTIVE_PAGES=$(vm_stat | grep "Pages active" | awk '{print $3}' | tr -d '.')
  INACTIVE_PAGES=$(vm_stat | grep "Pages inactive" | awk '{print $3}' | tr -d '.')

  FREE_BYTES=$((FREE_PAGES * PAGE_SIZE))
  WIRED_BYTES=$((WIRED_PAGES * PAGE_SIZE))
  ACTIVE_BYTES=$((ACTIVE_PAGES * PAGE_SIZE))
  INACTIVE_BYTES=$((INACTIVE_PAGES * PAGE_SIZE))
  USED_BYTES=$((ACTIVE_BYTES + WIRED_BYTES))
  AVAILABLE_BYTES=$((FREE_BYTES + INACTIVE_BYTES))
}

get_swap_info() {
  SWAP_TOTAL=$(sysctl -n vm.swapusage | awk '{print $7*1024*1024}')
  SWAP_USED=$(sysctl -n vm.swapusage | awk '{print $3*1024*1024}')
  SWAP_FREE=$(sysctl -n vm.swapusage | awk '{print $5*1024*1024}')
}

display_memory() {
  get_memory_info
  get_swap_info
  echo -e "${HEADER_COLOR}         total        used        free        available${RESET}"
  printf "${MEM_COLOR}Mem:${RESET}     %-12s %-12s %-12s %-12s\n" \
    "$(convert_unit $TOTAL_MEM)" "$(convert_unit $USED_BYTES)" \
    "$(convert_unit $FREE_BYTES)" "$(convert_unit $AVAILABLE_BYTES)"
  printf "${SWAP_COLOR}Swap:${RESET}    %-12s %-12s %-12s\n" \
    "$(convert_unit $SWAP_TOTAL)" "$(convert_unit $SWAP_USED)" "$(convert_unit $SWAP_FREE)"
  if [ $SHOW_TOTALS -eq 1 ]; then
    TOTAL_USED=$((USED_BYTES + SWAP_USED))
    TOTAL_FREE=$((FREE_BYTES + SWAP_FREE))
    printf "${TOTAL_COLOR}Total:${RESET}   %-12s %-12s %-12s\n" \
      "$(convert_unit $((TOTAL_MEM + SWAP_TOTAL)))" \
      "$(convert_unit $TOTAL_USED)" "$(convert_unit $TOTAL_FREE)"
  fi
}

show_help() {
  echo "Usage: free [options]"
  echo ""
  echo "Options:"
  echo "  -b, --bytes         Show output in bytes."
  echo "      --kilo          Show output in kilobytes."
  echo "      --mega          Show output in megabytes."
  echo "      --giga          Show output in gigabytes."
  echo "      --tera          Show output in terabytes."
  echo "      --peta          Show output in petabytes."
  echo "  -k, --kibi          Show output in kibibytes."
  echo "  -m, --mebi          Show output in mebibytes."
  echo "  -g, --gibi          Show output in gibibytes."
  echo "      --tebi          Show output in tebibytes."
  echo "      --pebi          Show output in pebibytes."
  echo "  -h, --human         Show human-readable output."
  echo "      --si            Use powers of 1000 not 1024."
  echo "  -l, --lohi          Show detailed low and high memory statistics."
  echo "  -L, --line          Show output on a single line."
  echo "  -t, --total         Show total for RAM + swap."
  echo "  -v, --committed     Show committed memory and commit limit."
  echo "  -s N, --seconds N   Repeat printing every N seconds."
  echo "  -c N, --count N     Repeat printing N times, then exit."
  echo "  -w, --wide          Wide output."
  echo "      --help          Display this help and exit."
  echo "  -V, --version       Output version information and exit."
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -b|--bytes) UNIT="bytes" ;;
    --kilo) UNIT="kilo" ;;
    --mega) UNIT="mega" ;;
    --giga) UNIT="giga" ;;
    --tera) UNIT="tera" ;;
    --peta) UNIT="peta" ;;
    -k|--kibi) UNIT="kibi" ;;
    -m|--mebi) UNIT="mebi" ;;
    -g|--gibi) UNIT="gibi" ;;
    --tebi) UNIT="tebi" ;;
    --pebi) UNIT="pebi" ;;
    -h|--human) HUMAN=1 ;;
    --si) SI=1 ;;
    -l|--lohi) SHOW_LOW_HIGH=1 ;;
    -L|--line) LINE=1 ;;
    -t|--total) SHOW_TOTALS=1 ;;
    -s|--seconds) DELAY=$2; shift ;;
    -c|--count) COUNT=$2; shift ;;
    -w|--wide) NO_COLOR=1 ;;
    --help) show_help; exit 0 ;;
    -V|--version) echo "choinek mac free based on free from procps-ng 4.0.4"; exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

apply_color

for ((i=1; i<=COUNT; i++)); do
  display_memory
  if [ $i -lt $COUNT ]; then
    sleep $DELAY
  fi
done
