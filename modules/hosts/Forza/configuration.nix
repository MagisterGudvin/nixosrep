{ self, ... }: {
  flake.nixosModules.ForzaConfiguration = {
    imports = [
      self.nixosModules.ForzaHardware
      self.nixosModules.system
      self.nixosModules.niri
      self.nixosModules.home
    ];
  };
}
