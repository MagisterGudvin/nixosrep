{ ... }: {
  flake.nixosModules.network = { ... }: {
    networking.hostName = "Forza";
    networking.networkmanager.enable = true;
    networking.useDHCP = false;
  };
}
