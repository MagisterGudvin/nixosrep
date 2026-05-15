#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_DIR="$REPO_ROOT/modules/hosts/forza"
SRC_CONFIG="${1:-/etc/nixos/configuration.nix}"
SRC_HW="${2:-/etc/nixos/hardware-configuration.nix}"

if [ ! -f "$SRC_CONFIG" ]; then
  echo "ERROR: $SRC_CONFIG not found" >&2
  exit 1
fi
if [ ! -f "$SRC_HW" ]; then
  echo "ERROR: $SRC_HW not found" >&2
  exit 1
fi

mkdir -p "$HOST_DIR"

cp "$SRC_HW" "$HOST_DIR/hardware-configuration.nix"

sed '/imports[[:space:]]*=[[:space:]]*\[[[:space:]]*\.\/hardware-configuration\.nix[[:space:]]*\];/d' \
    "$SRC_CONFIG" > "$HOST_DIR/original-configuration.nix"

cat > "$HOST_DIR/hardware.nix" <<'EOF'
{ self, inputs, ... }: {
  flake.nixosModules.forzaHardware = import ./hardware-configuration.nix;
}
EOF

cat > "$HOST_DIR/configuration.nix" <<'EOF'
{ self, inputs, ... }: {

  flake.nixosModules.forzaConfiguration = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.forzaHardware
      self.nixosModules.niri
      ./original-configuration.nix
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };

}
EOF

echo "Inserted:"
echo "  $HOST_DIR/hardware-configuration.nix"
echo "  $HOST_DIR/original-configuration.nix"
echo "Rewrote:"
echo "  $HOST_DIR/hardware.nix"
echo "  $HOST_DIR/configuration.nix"
echo
echo "Next: edit modules/hosts/forza/default.nix if you want to rename the host,"
echo "then run: sudo nixos-rebuild switch --flake .#forza"
