#!/bin/bash
# bootstrap.sh — Jackrose system bootstrap (root phase)
# Installs base packages, creates user, configures greetd, deploys configs.
set -euo pipefail

# ----- Defaults (preserve existing system settings when possible) -----
detect_timezone() {
  if [ -L /etc/localtime ]; then
    readlink -f /etc/localtime 2>/dev/null | sed 's|.*/zoneinfo/||' || echo "UTC"
  else
    echo "UTC"
  fi
}

detect_keymap() {
  if [ -f /etc/vconsole.conf ]; then
    grep -oP 'KEYMAP=\K.*' /etc/vconsole.conf 2>/dev/null || echo "us"
  else
    echo "us"
  fi
}

detect_locale() {
  if [ -f /etc/locale.conf ]; then
    grep -oP 'LANG=\K.*' /etc/locale.conf 2>/dev/null || echo "en_US.UTF-8"
  else
    echo "en_US.UTF-8"
  fi
}

# ----- CLI flags -----
USERNAME=""
TIMEZONE="$(detect_timezone)"
KEYMAP="$(detect_keymap)"
LOCALE="$(detect_locale)"
DRY_RUN=false
CHECK_ONLY=false
INSTALL=false
YES=false
PRESET=""

show_help() {
  echo "Usage: bootstrap.sh [options]"
  echo ""
  echo "Modes:"
  echo "  --check       Preflight system checks without making changes"
  echo "  --dry-run     Show the commands that would be executed"
  echo "  --install     Perform actual installation (requires root)"
  echo ""
  echo "Options:"
  echo "  --user <name>         Username to create/configure"
  echo "  --timezone <zone>     Timezone (default: detect from /etc/localtime)"
  echo "  --keymap <map>        Console keymap (default: detect from /etc/vconsole.conf)"
  echo "  --locale <loc>        System locale LANG (default: detect from /etc/locale.conf)"
  echo "  --preset japan        Shortcut: jp106 + Asia/Tokyo + ja_JP.UTF-8"
  echo "  --yes                 Skip non-dangerous prompts"
  echo "  --no-confirm          Skip all confirmation prompts"
  echo "  --help                Show this help message"
}

# Parse options
while [ $# -gt 0 ]; do
  case "$1" in
    --check) CHECK_ONLY=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --install) INSTALL=true; shift ;;
    --user)
      [ $# -ge 2 ] || { echo "Error: --user requires an argument" >&2; exit 1; }
      USERNAME="$2"; shift 2 ;;
    --timezone)
      [ $# -ge 2 ] || { echo "Error: --timezone requires an argument" >&2; exit 1; }
      TIMEZONE="$2"; shift 2 ;;
    --keymap)
      [ $# -ge 2 ] || { echo "Error: --keymap requires an argument" >&2; exit 1; }
      KEYMAP="$2"; shift 2 ;;
    --locale)
      [ $# -ge 2 ] || { echo "Error: --locale requires an argument" >&2; exit 1; }
      LOCALE="$2"; shift 2 ;;
    --preset)
      [ $# -ge 2 ] || { echo "Error: --preset requires an argument" >&2; exit 1; }
      PRESET="$2"; shift 2 ;;
    --yes) YES=true; shift ;;
    --no-confirm) YES=true; shift ;;
    --help|-h) show_help; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      show_help
      exit 1
      ;;
  esac
done

# Apply preset
if [ "$PRESET" = "japan" ]; then
  KEYMAP="jp106"
  TIMEZONE="Asia/Tokyo"
  LOCALE="ja_JP.UTF-8"
  echo "Preset 'japan' applied: keymap=$KEYMAP timezone=$TIMEZONE locale=$LOCALE"
fi

# ----- Logging -----
LOG_FILE="/var/log/jackrose/bootstrap.log"
if [ "$EUID" -eq 0 ]; then
  mkdir -p "$(dirname "$LOG_FILE")" || true
  exec > >(tee -a "$LOG_FILE") 2>&1 || true
fi

# ----- Helpers -----
run_cmd() {
  local desc="$1"
  shift
  if [ "$DRY_RUN" = true ]; then
    echo "[Dry-Run] Would run: $desc: $*"
  else
    echo "Running: $desc"
    "$@"
  fi
}

confirm() {
  if [ "$YES" = true ]; then
    return 0
  fi
  local prompt="$1"
  read -r -p "$prompt [y/N]: " answer
  [[ "$answer" =~ ^[yY] ]]
}

ask_username() {
  if [ -n "$USERNAME" ]; then
    echo "Using specified user: $USERNAME"
    return 0
  fi

  if [ "$YES" = true ]; then
    # Detect existing non-root user
    local existing
    existing=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1; exit}' /etc/passwd 2>/dev/null || echo "")
    if [ -n "$existing" ]; then
      USERNAME="$existing"
      echo "Auto-detected user: $USERNAME"
    else
      echo "Error: --yes requires --user when no existing normal user is found." >&2
      echo "Usage: bootstrap.sh --install --user <name> --yes" >&2
      exit 1
    fi
    return 0
  fi

  read -r -p "Enter username to create/configure: " USERNAME
  if [ -z "$USERNAME" ]; then
    echo "Username cannot be empty." >&2
    exit 1
  fi
}

# =====================================================================
preflight_check() {
  echo "=== Preflight Checks ==="
  local errors=0

  if [ -f /etc/arch-release ]; then
    echo "[OK] Arch-like environment detected."
  else
    echo "[WARN] /etc/arch-release not found."
  fi

  for cmd in pacman pacman-key systemctl sed locale-gen; do
    if command -v "$cmd" >/dev/null 2>&1; then
      echo "[OK] Command '$cmd' is available."
    else
      echo "[FAIL] Required command '$cmd' is missing."
      errors=$((errors + 1))
    fi
  done

  if [ "$EUID" -ne 0 ] && [ "$DRY_RUN" = false ]; then
    echo "[FAIL] Installation requires root privileges."
    errors=$((errors + 1))
  fi

  echo "Preflight checks finished. Total errors: $errors"
  return $errors
}

# =====================================================================
# Keyring detection — check what Asahi keyring is available
# =====================================================================
detect_keyring() {
  echo "=== Detecting Asahi Keyring ==="

  if pacman -Q asahi-alarm-keyring >/dev/null 2>&1; then
    echo "[OK] asahi-alarm-keyring is installed"
    echo "asahi-alarm"
    return
  fi

  if pacman -Q asahilinux-keyring >/dev/null 2>&1; then
    echo "[OK] asahilinux-keyring is installed"
    echo "asahilinux"
    return
  fi

  # Neither installed — try to install asahi-alarm-keyring
  echo "[INFO] No Asahi keyring detected. Will install asahi-alarm-keyring."
  echo "none"
}

# =====================================================================
# Greeter detection — check what greeter is available
# =====================================================================
detect_greeter() {
  echo "=== Detecting Greeter ==="

  if pacman -Si greetd-tuigreet >/dev/null 2>&1; then
    echo "[OK] greetd-tuigreet is available in repos"
    echo "greetd-tuigreet:tuigreet"
  else
    echo "[INFO] greetd-tuigreet not found in repos, using agreety (bundled with greetd)"
    echo "greetd:agreety"
  fi
}

# =====================================================================
# Main install
# =====================================================================
run_install() {
  echo "=== Jackrose Bootstrap Installer ==="
  echo "Started at $(date)"
  echo "  User:     ${USERNAME:-<will prompt>}"
  echo "  Timezone: $TIMEZONE"
  echo "  Keymap:   $KEYMAP"
  echo "  Locale:   $LOCALE"
  echo ""

  # ===================================================================
  # Step 1: Initialize pacman trust chain (canonical order from Asahi ALARM)
  # ===================================================================
  run_cmd "Initializing pacman keyring" pacman-key --init
  run_cmd "Populating archlinuxarm keyring" pacman-key --populate archlinuxarm || true

  # ===================================================================
  # Step 2: Sync pacman DB (now with trusted archlinuxarm keys)
  # ===================================================================
  run_cmd "Syncing pacman database" pacman -Sy --noconfirm

  # ===================================================================
  # Step 3: Install & trust Asahi keyring
  # ===================================================================
  local keyring_name
  keyring_name=$(detect_keyring)
  if [ "$keyring_name" = "none" ]; then
    run_cmd "Installing asahi-alarm-keyring" pacman -S --noconfirm --needed asahi-alarm-keyring || {
      echo "[INFO] asahi-alarm-keyring not available, trying asahilinux-keyring..."
      run_cmd "Installing asahilinux-keyring" pacman -S --noconfirm --needed asahilinux-keyring || true
    }
    keyring_name=$(detect_keyring)
  fi

  case "$keyring_name" in
    asahi-alarm)
      run_cmd "Populating asahi-alarm keyring" pacman-key --populate asahi-alarm || true
      ;;
    asahilinux)
      run_cmd "Populating asahilinux keyring" pacman-key --populate asahilinux || true
      ;;
    *)
      echo "[INFO] No Asahi keyring installed — Asahi packages may not be verifiable."
      ;;
  esac

  # Re-sync after keyring changes
  run_cmd "Re-syncing pacman database" pacman -Sy --noconfirm

  # ===================================================================
  # Step 4: System configuration (keyboard, timezone, locale)
  # ===================================================================
  run_cmd "Setting keyboard layout to $KEYMAP" sh -c "echo 'KEYMAP=$KEYMAP' > /etc/vconsole.conf"
  if command -v localectl >/dev/null 2>&1; then
    run_cmd "Registering keymap via localectl" localectl set-keymap "$KEYMAP" || true
  fi

  # --- Timezone ---
  if [ -f "/usr/share/zoneinfo/$TIMEZONE" ]; then
    run_cmd "Setting timezone to $TIMEZONE" ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
  else
    echo "[WARN] Timezone '$TIMEZONE' not found. Leaving /etc/localtime unchanged."
  fi

  # --- Locale ---
  if [ -f /etc/locale.gen ]; then
    local locale_base="${LOCALE%%.*}"  # e.g. "en_US" from "en_US.UTF-8"
    if ! grep -q "^$LOCALE " /etc/locale.gen 2>/dev/null && grep -q "#$LOCALE " /etc/locale.gen 2>/dev/null; then
      run_cmd "Enabling $LOCALE in locale.gen" sed -i "s|#$LOCALE |$LOCALE |" /etc/locale.gen
    fi
    # Also enable the base locale if different
    if [ "$locale_base.UTF-8" = "$LOCALE" ] && [ "$locale_base" != "$LOCALE" ]; then
      true  # already handled above
    fi
    run_cmd "Generating locales" locale-gen || true
  fi
  run_cmd "Setting default LANG locale" sh -c "echo 'LANG=$LOCALE' > /etc/locale.conf"

  # --- NetworkManager ---
  if command -v pacman >/dev/null 2>&1; then
    run_cmd "Installing NetworkManager" pacman -S --noconfirm --needed networkmanager || true
  fi
  if command -v systemctl >/dev/null 2>&1; then
    run_cmd "Enabling NetworkManager service" systemctl enable NetworkManager || true
    run_cmd "Starting NetworkManager service" systemctl start NetworkManager || true
  fi

  # --- User creation ---
  ask_username

  if id "$USERNAME" >/dev/null 2>&1; then
    echo "User $USERNAME already exists. Adding to wheel and standard groups..."
  else
    run_cmd "Creating user $USERNAME" useradd -m -G wheel,video,audio,input,power -s /bin/bash "$USERNAME"

    # Password: lock the account, force passwd on first login
    if [ "$DRY_RUN" = false ]; then
      if [ -t 0 ] && [ "$YES" = false ]; then
        echo "Set password for '$USERNAME':"
        passwd "$USERNAME"
      else
        # Non-interactive mode: lock password login, show next step
        passwd -l "$USERNAME"
        echo ""
        echo "============================================="
        echo "User '$USERNAME' created with password login locked."
        echo ""
        echo "Set password before login:"
        echo "  passwd $USERNAME"
        echo "============================================="
        echo ""
      fi
    fi
  fi

  # Ensure group memberships
  for grp in wheel video audio input power; do
    if getent group "$grp" >/dev/null 2>&1; then
      usermod -aG "$grp" "$USERNAME" 2>/dev/null || true
    fi
  done

  # --- Sudoers ---
  if [ -f /etc/sudoers ]; then
    run_cmd "Enabling wheel group sudo permissions" sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers 2>/dev/null || true
    run_cmd "Enabling wheel group sudo permissions (alt)" sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers 2>/dev/null || true
  fi

  # --- Greeter ---
  local greeter_info
  greeter_info=$(detect_greeter)
  local greeter_pkg="${greeter_info%%:*}"
  local greeter_cmd="${greeter_info##*:}"

  # Install packages
  local core_packages="base-devel git greetd $greeter_pkg foot fish fuzzel swaybg pipewire pipewire-alsa pipewire-pulse wireplumber rtkit speakersafetyd xorg-xwayland grim slurp wl-clipboard brightnessctl jq"
  # shellcheck disable=SC2086
  run_cmd "Installing core packages via pacman" pacman -S --noconfirm --needed $core_packages

  # Configure greetd
  run_cmd "Configuring greetd display manager" mkdir -p /etc/greetd
  if [ "$DRY_RUN" = false ]; then
    cat <<EOF > /etc/greetd/config.toml
[default_session]
command = "$greeter_cmd --time --cmd jackrose-session"
user = "greeter"
EOF
  else
    echo "[Dry-Run] Would write greetd config.toml (greeter: $greeter_cmd)"
  fi

  if command -v systemctl >/dev/null 2>&1; then
    run_cmd "Enabling greetd service" systemctl enable greetd || true
  fi

  # --- Deploy defaults to /usr/share/jackrose/defaults/ ---
  run_cmd "Creating defaults folders" mkdir -p /usr/share/jackrose/defaults/{niri,ghostty,fcitx5,environment.d,fish,starship,fuzzel,waybar,applications}

  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  JACKROSE_ROOT="$(dirname "$SCRIPT_DIR")"

  run_cmd "Deploying niri config"        cp -r "$JACKROSE_ROOT"/config/niri/*          /usr/share/jackrose/defaults/niri/
  run_cmd "Deploying Ghostty config"     cp -r "$JACKROSE_ROOT"/config/ghostty/*       /usr/share/jackrose/defaults/ghostty/
  run_cmd "Deploying Fcitx5 config"      cp -r "$JACKROSE_ROOT"/config/fcitx5/*        /usr/share/jackrose/defaults/fcitx5/
  run_cmd "Deploying environment vars"   cp -r "$JACKROSE_ROOT"/config/environment.d/* /usr/share/jackrose/defaults/environment.d/
  run_cmd "Deploying fish config"        cp -r "$JACKROSE_ROOT"/config/fish/*          /usr/share/jackrose/defaults/fish/
  run_cmd "Deploying Starship config"    cp -r "$JACKROSE_ROOT"/config/starship/*      /usr/share/jackrose/defaults/starship/
  run_cmd "Deploying fuzzel config"      cp -r "$JACKROSE_ROOT"/config/fuzzel/*        /usr/share/jackrose/defaults/fuzzel/
  run_cmd "Deploying Waybar config"      cp -r "$JACKROSE_ROOT"/config/waybar/*        /usr/share/jackrose/defaults/waybar/
  run_cmd "Deploying desktop entries"    cp -r "$JACKROSE_ROOT"/config/applications/*  /usr/share/jackrose/defaults/applications/

  run_cmd "Creating backgrounds folder" mkdir -p /usr/share/jackrose/backgrounds
  run_cmd "Deploying wallpaper"  cp "$JACKROSE_ROOT"/resources/backgrounds/jackrose-default.png /usr/share/jackrose/backgrounds/default.png

  # --- Install jackrose-session ---
  local pkg_dir="$JACKROSE_ROOT/packages/arch/jackrose-session"
  if [ -d "$pkg_dir" ]; then
    run_cmd "Installing jackrose-session runner"      cp "$pkg_dir/jackrose-session"        /usr/bin/jackrose-session
    run_cmd "Making session runner executable"     chmod +x /usr/bin/jackrose-session
    run_cmd "Installing desktop session entry"     cp "$pkg_dir/jackrose.desktop"        /usr/share/wayland-sessions/jackrose.desktop
    run_cmd "Creating systemd user config dir"     mkdir -p /usr/lib/systemd/user/
    run_cmd "Installing systemd session service"   cp "$pkg_dir/jackrose.service"        /usr/lib/systemd/user/jackrose.service
    run_cmd "Installing systemd shutdown target"   cp "$pkg_dir/jackrose-shutdown.target" /usr/lib/systemd/user/jackrose-shutdown.target
    run_cmd "Installing fcitx5 systemd service"    cp "$pkg_dir/fcitx5.service"       /usr/lib/systemd/user/fcitx5.service
  else
    echo "[WARN] jackrose-session package dir not found at $pkg_dir"
  fi

  # --- Install jackrose scripts to /usr/bin ---
  for script in jackrose-user-setup jackrose-welcome jackrose-oobe jackrose-healthcheck jackrose-firstboot-finish jackrose-audio jackrose-recovery jackrose-doctor jackrose-snapshot jackrose-repair; do
    local src_path=""
    case "$script" in
      jackrose-user-setup)        src_path="$JACKROSE_ROOT/components/config/bin/jackrose-user-setup" ;;
      jackrose-welcome)           src_path="$JACKROSE_ROOT/components/welcome/bin/jackrose-welcome" ;;
      jackrose-oobe)              src_path="$JACKROSE_ROOT/components/welcome/bin/jackrose-oobe" ;;
      jackrose-healthcheck)       src_path="$JACKROSE_ROOT/components/healthcheck/bin/jackrose-healthcheck" ;;
      jackrose-firstboot-finish)  src_path="$JACKROSE_ROOT/components/firstboot/bin/jackrose-firstboot-finish" ;;
      *)                       src_path="$JACKROSE_ROOT/scripts/$script" ;;
    esac

    if [ -f "$src_path" ]; then
      run_cmd "Installing $script" cp "$src_path" "/usr/bin/$script"
      run_cmd "Making $script executable" chmod +x "/usr/bin/$script"
    fi
  done

  # Install firstboot systemd unit
  if [ -f "$JACKROSE_ROOT/components/firstboot/systemd/jackrose-firstboot.service" ]; then
    run_cmd "Installing firstboot systemd unit" cp "$JACKROSE_ROOT/components/firstboot/systemd/jackrose-firstboot.service" "/usr/lib/systemd/system/jackrose-firstboot.service"
  fi


  # Also install lib/ if present
  if [ -d "$JACKROSE_ROOT/lib" ]; then
    run_cmd "Installing lib/ to /usr/lib/jackrose" mkdir -p /usr/lib/jackrose
    run_cmd "Copying lib/" cp -r "$JACKROSE_ROOT/lib/jackrose"/* /usr/lib/jackrose/
  fi

  # --- Recovery hints ---
  if [ "$DRY_RUN" = false ]; then
    cat <<EOF > /etc/jackrose-recovery-hints
=== Jackrose Recovery Hints ===
If niri or greetd fails to start:
1. Access fallback TTY using Ctrl+Alt+F2
2. Log in as your user
3. Run emergency commands:
   sudo jackrose-recovery disable-greetd
   jackrose-user-setup --force
   jackrose-repair --session
   jackrose-repair --configs
   jackrose-repair --audio
EOF
  else
    echo "[Dry-Run] Would write recovery hints to /etc/jackrose-recovery-hints"
  fi

  echo ""
  echo "=== Jackrose Bootstrap Complete ==="
  echo "Next: Switch to user '$USERNAME' and run:"
  echo "  cd $JACKROSE_ROOT"
  echo "  ./install.sh --desktop"
  echo ""
  echo "Or if you have a seed to resume:"
  echo "  ./install.sh --resume"
}

# =====================================================================
# Main
# =====================================================================

if [ $# -eq 0 ] && [ "$CHECK_ONLY" = false ] && [ "$DRY_RUN" = false ] && [ "$INSTALL" = false ]; then
  show_help
  exit 0
fi

preflight_check || {
  if [ "$CHECK_ONLY" = true ]; then
    exit 1
  elif [ "$DRY_RUN" = false ]; then
    echo "Preflight check failed. Aborting." >&2
    exit 1
  fi
}

if [ "$CHECK_ONLY" = true ]; then
  echo "Preflight checks passed. System is ready for install."
  exit 0
fi

run_install
