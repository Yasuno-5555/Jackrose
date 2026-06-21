#!/bin/bash
set -eo pipefail

LOG_FILE="/var/log/cidre/bootstrap.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Cidre Bootstrap Installer v0.2.0 ==="
echo "Started at $(date)"

# Root check
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root." >&2
  exit 1
fi

# Set keyboard map
echo "Setting keyboard layout to jp106..."
echo "KEYMAP=jp106" > /etc/vconsole.conf
if command -v localectl >/dev/null 2>&1; then
  localectl set-keymap jp106 || true
fi

# Set timezone and locale
echo "Setting timezone to Asia/Tokyo..."
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime || true

echo "Configuring locale (ja_JP.UTF-8, en_US.UTF-8)..."
if [ -f /etc/locale.gen ]; then
  sed -i 's/#ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
  sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
  locale-gen
fi
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Enable NetworkManager
echo "Configuring NetworkManager..."
if command -v pacman >/dev/null 2>&1; then
  pacman -S --noconfirm --needed networkmanager || true
fi
if command -v systemctl >/dev/null 2>&1; then
  systemctl enable NetworkManager || true
  systemctl start NetworkManager || true
fi

# Create Sudo User if not exist
# Check if stdin is a tty for interactive input, otherwise use defaults
if [ -t 0 ]; then
  read -p "Enter username to create/configure: " USERNAME
else
  USERNAME="cidre"
fi

if [ -z "$USERNAME" ]; then
  echo "Username cannot be empty."
  exit 1
fi

if id "$USERNAME" >/dev/null 2>&1; then
  echo "User $USERNAME already exists. Adding to wheel and standard groups..."
else
  useradd -m -G wheel,video,audio,input,power -s /bin/bash "$USERNAME"
  if [ -t 0 ]; then
    echo "Please set password for $USERNAME:"
    passwd "$USERNAME"
  else
    echo "$USERNAME:cidre" | chpasswd
    echo "Default password set to 'cidre'."
  fi
fi

# Configure sudoers
if [ -f /etc/sudoers ]; then
  sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
  sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
fi

# Update pacman keyring
echo "Initializing pacman keyring..."
pacman-key --init || true
pacman-key --populate archlinuxarm asahi || true
pacman -Sy --noconfirm || true

# Install base components
echo "Installing core packages..."
pacman -S --noconfirm --needed base-devel git greetd greetd-tuigreet foot fish fuzzel swaybg pipewire pipewire-alsa pipewire-pulse wireplumber rtkit speakersafetyd xorg-xwayland || true

# Configure greetd to launch Cidre (tuigreet with cidre-session)
echo "Configuring greetd..."
mkdir -p /etc/greetd
cat <<EOF > /etc/greetd/config.toml
[default_session]
command = "tuigreet --time --cmd cidre-session"
user = "greeter"
EOF

if command -v systemctl >/dev/null 2>&1; then
  systemctl enable greetd || true
fi

# Setup default configurations into /usr/share/cidre/defaults/
echo "Deploying default configurations to /usr/share/cidre/defaults/..."
mkdir -p /usr/share/cidre/defaults/niri
mkdir -p /usr/share/cidre/defaults/ghostty
mkdir -p /usr/share/cidre/defaults/fcitx5
mkdir -p /usr/share/cidre/defaults/environment.d
mkdir -p /usr/share/cidre/defaults/fish
mkdir -p /usr/share/cidre/defaults/starship
mkdir -p /usr/share/cidre/defaults/fuzzel
mkdir -p /usr/share/cidre/defaults/waybar
mkdir -p /usr/share/cidre/defaults/applications

# Copy default config files from script relative location or from cloned path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CIDRE_ROOT="$(dirname "$SCRIPT_DIR")"

cp -r "$CIDRE_ROOT"/config/niri/* /usr/share/cidre/defaults/niri/ || true
cp -r "$CIDRE_ROOT"/config/ghostty/* /usr/share/cidre/defaults/ghostty/ || true
cp -r "$CIDRE_ROOT"/config/fcitx5/* /usr/share/cidre/defaults/fcitx5/ || true
cp -r "$CIDRE_ROOT"/config/environment.d/* /usr/share/cidre/defaults/environment.d/ || true
cp -r "$CIDRE_ROOT"/config/fish/* /usr/share/cidre/defaults/fish/ || true
cp -r "$CIDRE_ROOT"/config/starship/* /usr/share/cidre/defaults/starship/ || true
cp -r "$CIDRE_ROOT"/config/fuzzel/* /usr/share/cidre/defaults/fuzzel/ || true
cp -r "$CIDRE_ROOT"/config/waybar/* /usr/share/cidre/defaults/waybar/ || true
cp -r "$CIDRE_ROOT"/config/applications/* /usr/share/cidre/defaults/applications/ || true

mkdir -p /usr/share/backgrounds
cp "$CIDRE_ROOT"/config/cidre-wallpaper.png /usr/share/backgrounds/cidre-wallpaper.png || true

# Install cidre-session binaries/systemd units
echo "Installing session components..."
cp "$CIDRE_ROOT"/packages/arch/cidre-session/cidre-session /usr/bin/cidre-session
chmod +x /usr/bin/cidre-session
cp "$CIDRE_ROOT"/packages/arch/cidre-session/cidre.desktop /usr/share/wayland-sessions/cidre.desktop || true
mkdir -p /usr/lib/systemd/user/
cp "$CIDRE_ROOT"/packages/arch/cidre-session/cidre.service /usr/lib/systemd/user/cidre.service || true
cp "$CIDRE_ROOT"/packages/arch/cidre-session/cidre-shutdown.target /usr/lib/systemd/user/cidre-shutdown.target || true

# Install cidre-user-setup into bin
cp "$CIDRE_ROOT"/scripts/cidre-user-setup /usr/bin/cidre-user-setup || true
chmod +x /usr/bin/cidre-user-setup || true

# Generate recovery hints
echo "Generating recovery hints at /etc/cidre-recovery-hints..."
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

echo "=== Cidre Bootstrap Complete ==="
echo "Please reboot to test greetd and the Cidre session."
