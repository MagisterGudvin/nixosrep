{ ... }: {
  flake.nixosModules.network = { ... }: {
    networking.networkmanager.enable = true;
    networking.useDHCP = false;
  };
}
