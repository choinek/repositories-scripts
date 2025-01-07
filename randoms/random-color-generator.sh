generate_random_color() {
  local style=$((RANDOM % 2 + 1))
  local foreground=$((RANDOM % 8 + 30))
  echo -e "\\033[${style};${foreground}m"
}
