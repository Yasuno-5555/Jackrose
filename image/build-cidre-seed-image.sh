#!/bin/bash
# build-cidre-seed-image.sh: Main orchestrator for Cidre target image assembly
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE=""
DRY_RUN=0
APPLY=0
FORCE_CLEAN=0

usage() {
  echo "Usage: $0 --profile <name> [--dry-run | --apply] [--force-clean]"
  echo "Options:"
  echo "  --profile <name>    Profile name to load (under image/profiles/<name>.conf)"
  echo "  --dry-run           Perform dry-run simulation"
  echo "  --apply             Perform real rootfs modification and packaging"
  echo "  --force-clean       Overwrites existing work directory"
  exit 1
}

# Parse parameters
while [ $# -gt 0 ]; do
  case "$1" in
    --profile)
      if [ $# -lt 2 ]; then
        echo "ERROR: --profile requires an argument." >&2
        exit 1
      fi
      PROFILE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --apply)
      APPLY=1
      shift
      ;;
    --force-clean)
      FORCE_CLEAN=1
      shift
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      usage
      ;;
  esac
done

if [ -z "$PROFILE" ]; then
  echo "ERROR: --profile is required." >&2
  usage
fi

if [ "$DRY_RUN" -eq 0 ] && [ "$APPLY" -eq 0 ]; then
  echo "ERROR: Use --dry-run or --apply explicitly." >&2
  exit 1
fi

# Load profile configuration
PROFILE_PATH="$SCRIPT_DIR/profiles/${PROFILE}.conf"
if [ ! -f "$PROFILE_PATH" ]; then
  echo "ERROR: Profile config not found at $PROFILE_PATH" >&2
  exit 1
fi

# Load variables
# shellcheck source=profiles/cidre-seed.conf
source "$PROFILE_PATH"

# Safety path resolution guards
TARGET_ROOTFS="${CIDRE_ROOTFS_DIR:-}"
if [ -z "$TARGET_ROOTFS" ] || [ "$TARGET_ROOTFS" = "/" ]; then
  echo "ERROR: TARGET_ROOTFS path resolves to host root '/' or empty. Aborting." >&2
  exit 1
fi

# Validate variables in apply mode
if [ "$APPLY" -eq 1 ] && [ -z "${CIDRE_BASE_ROOTFS:-}" ]; then
  echo "ERROR: CIDRE_BASE_ROOTFS is required for --apply mode." >&2
  exit 1
fi
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs/image-build"
LOG_FILE="$LOG_DIR/cidre-seed-$(date +%Y%m%d-%H%M).log"
mkdir -p "$LOG_DIR"

echo "=== Cidre Seed Image Builder ==="
echo "Profile loaded: $CIDRE_PROFILE_NAME ($CIDRE_ARCH)"
echo "Mode: $( [ "$DRY_RUN" -eq 1 ] && echo "DRY-RUN" || echo "APPLY" )"
echo ""

# 2. Check required host tools
echo "[Step 1/10] Checking required host tools..."
REQUIRED_TOOLS=(bash grep sed awk mkdir tar)
FUTURE_TOOLS=(chroot arch-chroot pacman xz zstd fakeroot systemd-nspawn)

missing_req=0
for tool in "${REQUIRED_TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "  [OK] Required tool: $tool"
  else
    echo "  [FAIL] Missing required tool: $tool" >&2
    missing_req=$((missing_req + 1))
  fi
done

if [ $missing_req -gt 0 ]; then
  echo "ERROR: Missing required tools for simulation." >&2
  exit 1
fi

for tool in "${FUTURE_TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "  [OK] Future tool: $tool"
  else
    echo "  [WARN] Missing tool (required for real apply mode): $tool"
  fi
done
echo ""

# 3. Base rootfs check
echo "[Step 2/10] Verifying base rootfs settings..."
if [ -z "${CIDRE_BASE_ROOTFS:-}" ]; then
  echo "  warning: CIDRE_BASE_ROOTFS is empty; rootfs extraction will be skipped in dry-run."
else
  echo "  Base rootfs targets: $CIDRE_BASE_ROOTFS"
fi
echo ""

# 4. Working directory setup
echo "[Step 3/10] Preparing workdir and out structures..."
if [ "$DRY_RUN" -eq 1 ]; then
  echo "  [DRY-RUN] would create workspace: $CIDRE_WORKDIR"
  echo "  [DRY-RUN] would create output dir: $CIDRE_OUTPUT_DIR"
else
  echo "Preparing workdir and directories..."
  mkdir -p "$CIDRE_OUTPUT_DIR"
fi
echo ""

# 5. Extract rootfs
echo "[Step 4/10] Extracting base rootfs..."
PREPARE_SCRIPT="$SCRIPT_DIR/scripts/prepare-rootfs"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "  [DRY-RUN] would execute: $PREPARE_SCRIPT --profile $PROFILE_PATH"
else
  CLEAN_FLAG=""
  if [ "$FORCE_CLEAN" -eq 1 ]; then
    CLEAN_FLAG="--force-clean"
  fi
  "$PREPARE_SCRIPT" --profile "$PROFILE_PATH" --apply $CLEAN_FLAG >> "$LOG_FILE" 2>&1
fi
echo ""

# 6. Install local packages
echo "[Step 5/10] Installing Cidre packages..."
INSTALL_SCRIPT="$SCRIPT_DIR/scripts/install-local-packages"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "  [DRY-RUN] would execute: $INSTALL_SCRIPT --rootfs $TARGET_ROOTFS --packages $CIDRE_LOCAL_PACKAGE_DIR --dry-run"
  "$INSTALL_SCRIPT" --rootfs "$TARGET_ROOTFS" --packages "$CIDRE_LOCAL_PACKAGE_DIR" --dry-run
else
  "$INSTALL_SCRIPT" --rootfs "$TARGET_ROOTFS" --packages "$CIDRE_LOCAL_PACKAGE_DIR" --apply >> "$LOG_FILE" 2>&1
fi
echo ""

# 7. Apply overlays
echo "[Step 6/10] Injecting filesystem overlays..."
OVERLAY_SRC="$SCRIPT_DIR/overlays/${PROFILE}"
OVERLAY_SCRIPT="$SCRIPT_DIR/scripts/apply-overlays"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "  [DRY-RUN] would execute: $OVERLAY_SCRIPT --rootfs $TARGET_ROOTFS --overlay $OVERLAY_SRC --dry-run"
  "$OVERLAY_SCRIPT" --rootfs "$TARGET_ROOTFS" --overlay "$OVERLAY_SRC" --dry-run
else
  "$OVERLAY_SCRIPT" --rootfs "$TARGET_ROOTFS" --overlay "$OVERLAY_SRC" --apply >> "$LOG_FILE" 2>&1
fi
echo ""

# 8. Enable firstboot service
echo "[Step 7/10] Registering firstboot services..."
ENABLE_SCRIPT="$SCRIPT_DIR/scripts/enable-firstboot"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "  [DRY-RUN] would execute: $ENABLE_SCRIPT --rootfs $TARGET_ROOTFS --dry-run"
  "$ENABLE_SCRIPT" --rootfs "$TARGET_ROOTFS" --dry-run
else
  "$ENABLE_SCRIPT" --rootfs "$TARGET_ROOTFS" --apply >> "$LOG_FILE" 2>&1
fi
echo ""

# 9. Lock root password login
echo "[Step 8/10] Enforcing root password policy..."
LOCK_SCRIPT="$SCRIPT_DIR/scripts/lock-root"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "  [DRY-RUN] would execute: $LOCK_SCRIPT --rootfs $TARGET_ROOTFS --dry-run"
  "$LOCK_SCRIPT" --rootfs "$TARGET_ROOTFS" --dry-run
else
  "$LOCK_SCRIPT" --rootfs "$TARGET_ROOTFS" --apply >> "$LOG_FILE" 2>&1
fi
echo ""

# 10. Run validation scripts
echo "[Step 9/10] Validating assembled rootfs..."
VALIDATOR="$SCRIPT_DIR/scripts/validate-rootfs"
if [ "$DRY_RUN" -eq 1 ]; then
  "$VALIDATOR" --rootfs "$TARGET_ROOTFS" --dry-run
else
  "$VALIDATOR" --rootfs "$TARGET_ROOTFS" >> "$LOG_FILE" 2>&1
fi
echo ""

# 11. Pack image
echo "[Step 10/10] Compressing output image..."
PACK_SCRIPT="$SCRIPT_DIR/scripts/pack-image"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "  [DRY-RUN] would execute: $PACK_SCRIPT --rootfs $TARGET_ROOTFS --output-dir $CIDRE_OUTPUT_DIR --name $CIDRE_IMAGE_NAME --dry-run"
  "$PACK_SCRIPT" --rootfs "$TARGET_ROOTFS" --output-dir "$CIDRE_OUTPUT_DIR" --name "$CIDRE_IMAGE_NAME" --dry-run
else
  "$PACK_SCRIPT" --rootfs "$TARGET_ROOTFS" --output-dir "$CIDRE_OUTPUT_DIR" --name "$CIDRE_IMAGE_NAME" --apply >> "$LOG_FILE" 2>&1
fi
echo ""

echo "=== Cidre Seed Image Builder Process Successful ==="
if [ "$APPLY" -eq 1 ]; then
  echo "Build log written to: $LOG_FILE"
fi
