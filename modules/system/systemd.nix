{ ... }: {
  flake.nixosModules.systemd = { ... }: {
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=15s
    '';
  };
}
