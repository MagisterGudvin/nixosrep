{ self, ... }: {
  flake.nixosModules.system = {
    imports = [
      self.nixosModules.audio
      self.nixosModules.boot
      self.nixosModules.cpu
      self.nixosModules.filesystems
      self.nixosModules.locale
      self.nixosModules.network
      self.nixosModules.nix
      self.nixosModules.packages
      self.nixosModules.polkit
      self.nixosModules.radeon
      self.nixosModules.services
      self.nixosModules.systemd
      self.nixosModules.users
    ];
  };
}
