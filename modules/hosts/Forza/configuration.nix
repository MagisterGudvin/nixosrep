{ self, inputs, ... }: {

  flake.nixosModules.ForzaConfiguration = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.ForzaHardware
  };

}
