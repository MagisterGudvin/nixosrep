{ ... }: {
  flake.nixosModules.services = { ... }: {
    services.openssh.enable = false;
    services.printing.enable = false;
  };
}
