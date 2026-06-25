#!/bin/bash
# lib/cidre/ui.sh — Cidre shared TUI display helpers
# Source this file: source "$CIDRE_ROOT/lib/cidre/ui.sh"
set -euo pipefail

# Color support
if [ -z "${NO_COLOR:-}" ] && [ -t 1 ]; then
  C_GREEN='\e[32m'
  C_YELLOW='\e[33m'
  C_RED='\e[31m'
  C_CYAN='\e[36m'
  C_MAGENTA='\e[35m'
  C_BOLD='\e[1m'
  C_RESET='\e[0m'
else
  C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''; C_MAGENTA=''; C_BOLD=''; C_RESET=''
fi

# ----- Status line helpers -----

cidre_ok() {
  echo -e "[${C_GREEN}OK${C_RESET}] $*"
}

cidre_warn() {
  echo -e "[${C_YELLOW}WARN${C_RESET}] $*"
}

cidre_fail() {
  echo -e "[${C_RED}FAIL${C_RESET}] $*"
}

cidre_info() {
  echo -e "[${C_CYAN}INFO${C_RESET}] $*"
}

# ----- Banner -----

cidre_banner() {
  echo -e "${C_CYAN}====================================================${C_RESET}"
  echo -e "${C_MAGENTA}               Cidre Installer                      ${C_RESET}"
  echo -e "${C_CYAN}====================================================${C_RESET}"
  echo "  The cider after Homebrew."
  echo ""
}

# ----- Confirmation -----

# Ask yes/no. Returns 0 for yes, 1 for no.
# If CIDRE_YES is set, auto-confirms.
cidre_confirm() {
  local prompt="$1"
  local default="${2:-N}"

  if [ "${CIDRE_YES:-false}" = true ]; then
    echo "${prompt} [auto-confirmed with --yes]"
    return 0
  fi

  local yn="y/N"
  if [ "$default" = "Y" ]; then
    yn="Y/n"
  fi

  printf "%s [%s]: " "$prompt" "$yn"
  read -r answer

  if [ "$default" = "Y" ]; then
    [[ ! "$answer" =~ ^[nN] ]]
  else
    [[ "$answer" =~ ^[yY]([eE][sS])?$ ]]
  fi
}

# ----- Brand promise -----

cidre_brand_promise() {
  echo ""
  echo -e "${C_BOLD}Cidre will NOT change:${C_RESET}"
  echo "  - macOS default boot"
  echo "  - NVRAM boot order"
  echo "  - boot policy"
  echo "  - recovery partition"
  echo ""
}

cidre_brand_confirm() {
  cidre_brand_promise
  if ! cidre_confirm "Continue?"; then
    echo "Installation cancelled."
    exit 0
  fi
}

# ----- Failure UX (the "good" error pattern) -----

# Display a failure with causes, recovery steps, and log path
# Usage: cidre_failure_report "pacman database sync failed" \
#   "Network is unavailable" "Mirror is temporarily unreachable" "pacman keyring is outdated" \
#   "sudo pacman -Syy" "sudo pacman -Sy archlinuxarm-keyring" "./install.sh --retry"
cidre_failure_report() {
  local title="$1"
  shift

  # Collect "Likely causes" and "Try" lines
  local causes=()
  local tries=()
  local in_try=false

  while [ $# -gt 0 ]; do
    if [ "$1" = "--try" ]; then
      in_try=true
      shift
      continue
    fi
    if [ "$in_try" = true ]; then
      tries+=("$1")
    else
      causes+=("$1")
    fi
    shift
  done

  echo ""
  echo -e "${C_RED}${C_BOLD}[FAILED]${C_RESET} ${title}"
  echo ""

  if [ ${#causes[@]} -gt 0 ]; then
    echo "Likely causes:"
    for cause in "${causes[@]}"; do
      echo "  - $cause"
    done
    echo ""
  fi

  if [ ${#tries[@]} -gt 0 ]; then
    echo "Try:"
    for try in "${tries[@]}"; do
      echo "  $try"
    done
    echo ""
  fi

  cidre_log_path
}

# ----- Progress -----

cidre_section() {
  echo ""
  echo -e "${C_BOLD}=== $1 ===${C_RESET}"
}

# ----- Menu -----

# Simple numbered menu
# Usage: cidre_menu "Title" "option1" "desc1" "option2" "desc2" ...
# Returns the selected option key on stdout
cidre_menu() {
  local title="$1"
  shift
  local items=("$@")
  local count=$((${#items[@]} / 2))

  echo ""
  echo -e "${C_BOLD}${title}${C_RESET}"
  echo ""

  for ((i=0; i<count; i++)); do
    local idx=$((i + 1))
    local key="${items[$((i*2))]}"
    local desc="${items[$((i*2 + 1))]}"
    printf "  [%d] %-20s %s\n" "$idx" "$key" "$desc"
  done

  echo ""
  printf "Select option [1-%d]: " "$count"
  read -r opt

  if [[ "$opt" =~ ^[0-9]+$ ]] && [ "$opt" -ge 1 ] && [ "$opt" -le "$count" ]; then
    echo "${items[$(((opt-1)*2))]}"
  else
    echo ""
  fi
}

# ----- Next steps display -----

cidre_next_steps() {
  echo ""
  echo -e "${C_BOLD}Next steps:${C_RESET}"
  echo "  1. Reboot the system or log out."
  echo "  2. Select the 'Cidre' graphical session at the greeter."
  echo "  3. On first login, run 'cidre-welcome' for a guided tour."
  echo ""
  echo -e "${C_BOLD}Maintenance Commands:${C_RESET}"
  echo "  * System diagnostics:   cidre-doctor --daily"
  echo "  * Config reset:         cidre-repair --configs"
  echo "  * Audio fix:            cidre-repair --audio"
  echo "  * Full recovery:        cidre-recovery status"
  echo ""
}
