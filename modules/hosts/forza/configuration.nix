{ self, ... }: {
  flake.nixosModules.forzaConfiguration = {
    imports = [
      self.nixosModules.forzaHardware
      self.nixosModules.system
      self.nixosModules.home
    ];
  };
}
