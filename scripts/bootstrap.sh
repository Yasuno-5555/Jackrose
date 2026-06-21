#!/bin/bash
set -eo pipefail

LOG_FILE="/var/log/cidre/bootstrap.log"
if [ "$EUID" -eq 0 ]; then
  mkdir -p "$(dirname "$LOG_FILE")" || true
  exec > >(tee -a "$LOG_FILE") 2>&1 || true
fi

DRY_RUN=false
CHECK_ONLY=false
INSTALL=false

show_help() {
  echo "Usage: bootstrap.sh [options]"
  echo "Options:"
  echo "  --check       Perform preflight system checks without making changes"
  echo "  --dry-run     Show the commands that would be executed"
  echo "  --install     Perform actual installation of Cidre environment"
  echo "  --help        Show this help message"
}

# Parse options
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

for arg in "$@"; do
  case "$arg" in
    --check)
      CHECK_ONLY=true
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    --install)
      INSTALL=true
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      show_help
      exit 1
      ;;
  esac
done

# Wrapper for running command
run_cmd() {
  local desc="$1"
  shift
  if [ "$DRY_RUN" = true ]; then
    echo "[Dry-Run] Would run: $*"
  else
    echo "Running: $desc"
    "$@"
  fi
}

preflight_check() {
  echo "=== Running Preflight Checks ==="
  local errors=0
  
  if [ -f /etc/arch-release ]; then
    echo "[OK] Arch-like environment detected."
  else
    echo "[WARN] /etc/arch-release not found. This does not look like Arch/ALARM."
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
    echo "[FAIL] Installation requires root privileges. Please run as root."
    errors=$((errors + 1))
  fi

  echo "Preflight checks finished. Total errors: $errors"
  return $errors
}

# Run preflight
preflight_check || {
  if [ "$CHECK_ONLY" = true ]; then
    exit 1
  elif [ "$DRY_RUN" = false ]; then
    echo "Preflight check failed. Aborting." >&2
    exit 1
  fi
}

if [ "$CHECK_ONLY" = true ]; then
  echo "Preflight checks passed successfully. System is ready for install."
  exit 0
fi

echo "=== Cidre Bootstrap Installer ==="
echo "Started at $(date)"

# Set keyboard map
run_cmd "Setting keyboard layout to jp106" sh -c "echo 'KEYMAP=jp106' > /etc/vconsole.conf"
if command -v localectl >/dev/null 2>&1; then
  run_cmd "Registering keymap via localectl" localectl set-keymap jp106 || true
fi

# Set timezone and locale
run_cmd "Setting timezone to Asia/Tokyo" ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
if [ -f /etc/locale.gen ]; then
  run_cmd "Enabling ja_JP/en_US locale generation" sed -i 's/#ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
  run_cmd "Enabling en_US locale generation" sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
  run_cmd "Generating locales" locale-gen || true
fi
run_cmd "Setting default LANG locale" sh -c "echo 'LANG=en_US.UTF-8' > /etc/locale.conf"

# Enable NetworkManager
if command -v pacman >/dev/null 2>&1; then
  run_cmd "Installing NetworkManager" pacman -S --noconfirm --needed networkmanager || true
fi
if command -v systemctl >/dev/null 2>&1; then
  run_cmd "Enabling NetworkManager service" systemctl enable NetworkManager || true
  run_cmd "Starting NetworkManager service" systemctl start NetworkManager || true
fi

# Sudo user setup
if [ -t 0 ] && [ "$DRY_RUN" = false ]; then
  read -p "Enter username to create/configure: " USERNAME
else
  USERNAME="cidre"
fi

if [ -z "$USERNAME" ]; then
  echo "Username cannot be empty." >&2
  exit 1
fi

if id "$USERNAME" >/dev/null 2>&1; then
  echo "User $USERNAME already exists. Adding to wheel and standard groups..."
else
  run_cmd "Creating sudo user $USERNAME" useradd -m -G wheel,video,audio,input,power -s /bin/bash "$USERNAME"
  if [ -t 0 ] && [ "$DRY_RUN" = false ]; then
    passwd "$USERNAME"
  else
    run_cmd "Setting default password for $USERNAME" sh -c "echo '$USERNAME:cidre' | chpasswd"
  fi
fi

# Configure sudoers
if [ -f /etc/sudoers ]; then
  run_cmd "Enabling wheel group sudo permissions" sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
  run_cmd "Enabling wheel group sudo permissions (alternative format)" sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
fi

# Update pacman keyring
run_cmd "Initializing pacman keyring" pacman-key --init
run_cmd "Populating keyrings" pacman-key --populate archlinuxarm asahi
run_cmd "Syncing pacman database" pacman -Sy --noconfirm

# Install base components
run_cmd "Installing core packages via pacman" pacman -S --noconfirm --needed base-devel git greetd greetd-tuigreet foot fish fuzzel swaybg pipewire pipewire-alsa pipewire-pulse wireplumber rtkit speakersafetyd xorg-xwayland grim slurp wl-clipboard brightnessctl jq

# Configure greetd to launch Cidre (tuigreet with cidre-session)
run_cmd "Configuring greetd display manager" mkdir -p /etc/greetd
if [ "$DRY_RUN" = false ]; then
  cat <<EOF > /etc/greetd/config.toml
[default_session]
command = "tuigreet --time --cmd cidre-session"
user = "greeter"
EOF
else
  echo "[Dry-Run] Would write greetd config.toml"
fi

if command -v systemctl >/dev/null 2>&1; then
  run_cmd "Enabling greetd service" systemctl enable greetd || true
fi

# Setup default configurations into /usr/share/cidre/defaults/
run_cmd "Creating defaults folders" mkdir -p /usr/share/cidre/defaults/niri /usr/share/cidre/defaults/ghostty /usr/share/cidre/defaults/fcitx5 /usr/share/cidre/defaults/environment.d /usr/share/cidre/defaults/fish /usr/share/cidre/defaults/starship /usr/share/cidre/defaults/fuzzel /usr/share/cidre/defaults/waybar /usr/share/cidre/defaults/applications

# Copy default config files from script relative location or from cloned path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CIDRE_ROOT="$(dirname "$SCRIPT_DIR")"

run_cmd "Deploying niri config" cp -r "$CIDRE_ROOT"/config/niri/* /usr/share/cidre/defaults/niri/
run_cmd "Deploying Ghostty config" cp -r "$CIDRE_ROOT"/config/ghostty/* /usr/share/cidre/defaults/ghostty/
run_cmd "Deploying Fcitx5 config" cp -r "$CIDRE_ROOT"/config/fcitx5/* /usr/share/cidre/defaults/fcitx5/
run_cmd "Deploying environment vars" cp -r "$CIDRE_ROOT"/config/environment.d/* /usr/share/cidre/defaults/environment.d/
run_cmd "Deploying fish config" cp -r "$CIDRE_ROOT"/config/fish/* /usr/share/cidre/defaults/fish/
run_cmd "Deploying Starship config" cp -r "$CIDRE_ROOT"/config/starship/* /usr/share/cidre/defaults/starship/
run_cmd "Deploying fuzzel config" cp -r "$CIDRE_ROOT"/config/fuzzel/* /usr/share/cidre/defaults/fuzzel/
run_cmd "Deploying Waybar config" cp -r "$CIDRE_ROOT"/config/waybar/* /usr/share/cidre/defaults/waybar/
run_cmd "Deploying Ghostty desktop file" cp -r "$CIDRE_ROOT"/config/applications/* /usr/share/cidre/defaults/applications/

run_cmd "Creating backgrounds folder" mkdir -p /usr/share/backgrounds
run_cmd "Deploying desktop wallpaper" cp "$CIDRE_ROOT"/config/cidre-wallpaper.png /usr/share/backgrounds/cidre-wallpaper.png

# Install cidre-session binaries/systemd units
run_cmd "Installing cidre-session runner" cp "$CIDRE_ROOT"/packages/arch/cidre-session/cidre-session /usr/bin/cidre-session
run_cmd "Making session runner executable" chmod +x /usr/bin/cidre-session
run_cmd "Installing desktop session entry" cp "$CIDRE_ROOT"/packages/arch/cidre-session/cidre.desktop /usr/share/wayland-sessions/cidre.desktop
run_cmd "Creating systemd user config directory" mkdir -p /usr/lib/systemd/user/
run_cmd "Installing systemd session service" cp "$CIDRE_ROOT"/packages/arch/cidre-session/cidre.service /usr/lib/systemd/user/cidre.service
run_cmd "Installing systemd shutdown target" cp "$CIDRE_ROOT"/packages/arch/cidre-session/cidre-shutdown.target /usr/lib/systemd/user/cidre-shutdown.target
run_cmd "Installing fcitx5 systemd service" cp "$CIDRE_ROOT"/packages/arch/cidre-session/fcitx5.service /usr/lib/systemd/user/fcitx5.service

# Install cidre scripts into bin
run_cmd "Installing user-setup script" cp "$CIDRE_ROOT"/scripts/cidre-user-setup /usr/bin/cidre-user-setup
run_cmd "Making user-setup executable" chmod +x /usr/bin/cidre-user-setup
run_cmd "Installing welcome script" cp "$CIDRE_ROOT"/scripts/cidre-welcome /usr/bin/cidre-welcome
run_cmd "Making welcome executable" chmod +x /usr/bin/cidre-welcome
run_cmd "Installing audio manager script" cp "$CIDRE_ROOT"/scripts/cidre-audio /usr/bin/cidre-audio
run_cmd "Making audio manager executable" chmod +x /usr/bin/cidre-audio
run_cmd "Installing recovery script" cp "$CIDRE_ROOT"/scripts/cidre-recovery /usr/bin/cidre-recovery
run_cmd "Making recovery executable" chmod +x /usr/bin/cidre-recovery
run_cmd "Installing diagnostics doctor script" cp "$CIDRE_ROOT"/scripts/cidre-doctor /usr/bin/cidre-doctor
run_cmd "Making doctor executable" chmod +x /usr/bin/cidre-doctor
run_cmd "Installing firstboot validator script" cp "$CIDRE_ROOT"/scripts/cidre-firstboot /usr/bin/cidre-firstboot
run_cmd "Making firstboot executable" chmod +x /usr/bin/cidre-firstboot
run_cmd "Installing snapshot utility script" cp "$CIDRE_ROOT"/scripts/cidre-snapshot /usr/bin/cidre-snapshot
run_cmd "Making snapshot utility executable" chmod +x /usr/bin/cidre-snapshot

# Generate recovery hints
run_cmd "Generating recovery hints at /etc/cidre-recovery-hints" sh -c "echo 'Cidre Recovery Hints generated' > /dev/null"
if [ "$DRY_RUN" = false ]; then
  cat <<EOF > /etc/cidre-recovery-hints
=== Cidre Recovery Hints ===
If niri or greetd fails to start:
1. Access fallback TTY using Ctrl+Alt+F2
2. Log in as your sudo user
3. Run emergency command:
   sudo cidre-recovery disable-greetd
4. Reset configurations if needed:
   cidre-user-setup --force
EOF
fi

echo "=== Cidre Bootstrap Complete ==="
echo "Please reboot to test greetd and the Cidre session."
