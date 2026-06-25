#!/bin/bash
# lib/cidre/checks.sh — Cidre shared system check functions
# Source this file: source "$CIDRE_ROOT/lib/cidre/checks.sh"
set -euo pipefail

# Source UI if not already loaded
if ! declare -f cidre_ok >/dev/null 2>&1; then
  CIDRE_ROOT="${CIDRE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  source "$CIDRE_ROOT/lib/cidre/ui.sh"
fi

# ----- Individual checks (return 0 = pass, 1 = fail) -----

check_is_arch() {
  [ -f /etc/arch-release ]
}

check_is_apple_silicon() {
  [ -d /proc/device-tree/asahi ] || grep -qi "asahi" /proc/cpuinfo 2>/dev/null || [ -d /sys/firmware/devicetree/base/asahi ]
}

check_command() {
  command -v "$1" >/dev/null 2>&1
}

check_pacman_initialized() {
  [ -d /var/lib/pacman/sync ] && [ -n "$(ls -A /var/lib/pacman/sync 2>/dev/null)" ]
}

check_network_up() {
  ip -o link show up 2>/dev/null | grep -qv "LOOPBACK"
}

check_default_route() {
  ip route show default 2>/dev/null | grep -q '^default'
}

check_dns() {
  getent ahosts archlinux.org >/dev/null 2>&1 || getent ahosts github.com >/dev/null 2>&1
}

check_repo_reachable() {
  curl -fsI --max-time 5 https://github.com >/dev/null 2>&1 || \
    curl -fsI --max-time 5 https://archlinux.org >/dev/null 2>&1 || \
    ping -c 1 -W 2 archlinux.org >/dev/null 2>&1
}

check_system_clock() {
  local year
  year=$(date +%Y)
  [ "$year" -ge 2026 ]
}

check_normal_user_exists() {
  awk -F: '$3 >= 1000 && $1 != "nobody" {found=1; exit} END {exit !found}' /etc/passwd
}

check_wheel_user() {
  local wheel_users
  wheel_users=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | while read -r u; do
    if id -nG "$u" 2>/dev/null | grep -qw "wheel"; then echo "$u"; fi
  done)
  [ -n "$wheel_users" ]
}

check_sudo_configured() {
  command -v sudo >/dev/null 2>&1 && \
    [ -f /etc/sudoers.d/cidre-wheel ] && \
    grep -q '^%wheel ALL=(ALL:ALL) ALL$' /etc/sudoers.d/cidre-wheel 2>/dev/null
}

check_filesystem_writable() {
  [ -w /tmp ]
}

check_disk_space() {
  local free_space
  free_space=$(df / --output=avail 2>/dev/null | tail -n 1 || echo 0)
  [ "$free_space" -gt 5242880 ]  # 5GB in 1K blocks
}

# ----- Composite check runners -----

# Run a check and print [OK]/[WARN]/[FAIL]
# Usage: run_check "OK" "message" <command>
#        run_check "FAIL" "message" <command>  (inverts: command must succeed)
run_check() {
  local fail_severity="$1"
  local ok_msg="$2"
  shift 2

  if "$@"; then
    if [ "$fail_severity" = "FAIL" ]; then
      cidre_fail "$ok_msg"
      return 1
    else
      cidre_ok "$ok_msg"
      return 0
    fi
  else
    if [ "$fail_severity" = "FAIL" ]; then
      cidre_ok "$ok_msg"
      return 0
    else
      cidre_fail "$ok_msg"
      return 1
    fi
  fi
}

# Run all base readiness checks and return counts
# Usage: cidre_run_base_checks
# Sets: CHECK_OK, CHECK_WARN, CHECK_FAIL
cidre_run_base_checks() {
  CHECK_OK=0
  CHECK_WARN=0
  CHECK_FAIL=0

  local check
  declare -A checks=(
    ["Arch/ALARM base"]="check_is_arch"
    ["Apple Silicon / Asahi"]="check_is_apple_silicon"
    ["pacman"]="check_command pacman"
    ["pacman database"]="check_pacman_initialized"
    ["systemctl"]="check_command systemctl"
    ["sudo"]="check_command sudo"
    ["bash"]="check_command bash"
    ["python3"]="check_command python3"
    ["git"]="check_command git"
    ["curl"]="check_command curl"
    ["network interface"]="check_network_up"
    ["default route"]="check_default_route"
    ["DNS resolution"]="check_dns"
    ["system clock"]="check_system_clock"
    ["normal user"]="check_normal_user_exists"
    ["wheel user"]="check_wheel_user"
    ["sudo policy"]="check_sudo_configured"
    ["filesystem writable"]="check_filesystem_writable"
    ["disk space"]="check_disk_space"
  )

  for label in "${!checks[@]}"; do
    local cmd="${checks[$label]}"
    local severity="WARN"
    # Critical checks
    case "$label" in
      "pacman"|"sudo"|"bash"|"network interface"|"DNS resolution"|"filesystem writable")
        severity="FAIL"
        ;;
    esac

    if eval "$cmd"; then
      cidre_ok "$label"
      CHECK_OK=$((CHECK_OK + 1))
    else
      if [ "$severity" = "FAIL" ]; then
        cidre_fail "$label"
        CHECK_FAIL=$((CHECK_FAIL + 1))
      else
        cidre_warn "$label"
        CHECK_WARN=$((CHECK_WARN + 1))
      fi
    fi
  done
}

# Run a check with failure report on failure
# Usage: check_with_recovery "label" "command" "cause1" "cause2" --try "fix1" "fix2"
check_with_recovery() {
  local label="$1"
  local cmd="$2"
  shift 2

  if eval "$cmd"; then
    cidre_ok "$label"
    return 0
  else
    cidre_fail "$label"
    cidre_failure_report "$label" "$@"
    return 1
  fi
}
