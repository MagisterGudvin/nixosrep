{ ... }: {
  flake.nixosModules.filesystems = { ... }: {
    services.fstrim.enable = true;
  };
}
