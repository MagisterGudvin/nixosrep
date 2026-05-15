{ ... }: {
  flake.nixosModules.networking = { ... }: {
    networking.networkmanager.enable = true;
    networking.useDHCP = false;
  };
}
