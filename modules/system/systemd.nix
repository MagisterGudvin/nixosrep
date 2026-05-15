{ ... }: {
  flake.nixosModules.systemd = { ... }: {
    systemd.settings.Manager.DefaultTimeoutStopSec = "15s";
  };
}
