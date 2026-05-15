{ self, inputs, ... }: {

  flake.nixosModules.ForzaConfiguration = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.ForzaHardware

      self.nixosModules.system

      self.nixosModules.niri

      self.nixosModules.home
    ];
  };

}
