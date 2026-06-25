#!/bin/bash
# lib/cidre/log.sh — Cidre shared logging utilities
# Source this file: source "$CIDRE_ROOT/lib/cidre/log.sh"
set -euo pipefail

# Ensure CIDRE_ROOT is set by the caller, or derive it
if [ -z "${CIDRE_ROOT:-}" ]; then
  CIDRE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

: "${CIDRE_LOG_DIR:=$HOME/.local/state/cidre}"
: "${CIDRE_LOG_FILE:=$CIDRE_LOG_DIR/install.log}"

# Initialize logging — call once at script start
cidre_log_init() {
  mkdir -p "$CIDRE_LOG_DIR"
  local log_name="${1:-install}"
  CIDRE_LOG_FILE="${CIDRE_LOG_DIR}/${log_name}-$(date +%Y%m%d-%H%M%S).log"

  # Tee all output to log file
  exec > >(tee -a "$CIDRE_LOG_FILE") 2>&1

  echo "Cidre log started at $(date -Is)"
  echo "Log file: $CIDRE_LOG_FILE"
  echo ""
}

# Log a line with timestamp
cidre_log() {
  printf '[%s] %s\n' "$(date -Is)" "$*" >> "${CIDRE_LOG_FILE:-/dev/null}"
}

# Log an error and show it to the user
cidre_log_error() {
  local context="$1"
  local message="$2"
  cidre_log "ERROR [$context]: $message"
  echo -e "\e[1;31m[ERROR]\e[0m $message" >&2
}

# Log the final result path
cidre_log_path() {
  echo ""
  echo "Log: ${CIDRE_LOG_FILE:-$HOME/.local/state/cidre/install.log}"
}
