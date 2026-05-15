{ self, inputs, ... }: {

  flake.nixosModules.myMachineConfiguration = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.myMachineHardware

      self.nixosModules.locale
      self.nixosModules.audio
      self.nixosModules.radeon
      self.nixosModules.networking
      self.nixosModules.users
      self.nixosModules.systemPackages

      self.nixosModules.niri

      self.nixosModules.home
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };

}
