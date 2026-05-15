{ ... }: {
  flake.nixosModules.network = { ... }: {
    networking.hostName = "forza";
    networking.networkmanager.enable = true;
    networking.useDHCP = false;
  };
}
