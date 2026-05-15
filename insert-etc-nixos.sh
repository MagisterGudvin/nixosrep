#!/usr/bin/env bash
# Sync hardware-configuration.nix from nixos-generate-config into the repo.
#
# Usage (from live ISO, target system mounted on /mnt):
#   sudo ./insert-etc-nixos.sh
#
# Or pass a custom mount root:
#   sudo ./insert-etc-nixos.sh /mnt
#
# What it does:
#   1. Runs `nixos-generate-config --no-filesystems --root <root>` into a
#      temp dir (so the live host's /etc/nixos isn't touched).
#   2. Copies the resulting hardware-configuration.nix into
#      modules/hosts/Forza/.
#   3. Rewrites modules/hosts/Forza/hardware.nix to a thin flake-parts
#      wrapper that re-exports hardware-configuration.nix as
#      flake.nixosModules.ForzaHardware.
#
# Why --no-filesystems: filesystems and swap are described declaratively
# in modules/system/filesystems.nix; we don't want a duplicate
# auto-detected definition that conflicts.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_DIR="$REPO_ROOT/modules/hosts/Forza"
ROOT="${1:-/mnt}"

if [ ! -d "$ROOT" ]; then
  echo "ERROR: root '$ROOT' does not exist. Pass the mountpoint of the target system." >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==> Running nixos-generate-config --no-filesystems --root $ROOT --dir $TMP_DIR"
nixos-generate-config --no-filesystems --root "$ROOT" --dir "$TMP_DIR"

if [ ! -f "$TMP_DIR/hardware-configuration.nix" ]; then
  echo "ERROR: $TMP_DIR/hardware-configuration.nix not produced" >&2
  exit 1
fi

mkdir -p "$HOST_DIR"

echo "==> Copying hardware-configuration.nix into $HOST_DIR"
cp "$TMP_DIR/hardware-configuration.nix" "$HOST_DIR/hardware-configuration.nix"

echo "==> Rewriting $HOST_DIR/hardware.nix as flake-parts wrapper"
cat > "$HOST_DIR/hardware.nix" <<'EOF'
{ ... }: {
  flake.nixosModules.ForzaHardware = import ./hardware-configuration.nix;
}
EOF

echo
echo "Done."
echo "  Updated: $HOST_DIR/hardware-configuration.nix"
echo "  Updated: $HOST_DIR/hardware.nix"
echo
echo "Next steps:"
echo "  cd $REPO_ROOT"
echo "  git diff modules/hosts/Forza/"
echo "  git add modules/hosts/Forza/hardware-configuration.nix modules/hosts/Forza/hardware.nix"
echo "  git commit -m 'Sync hardware-configuration for Forza'"
