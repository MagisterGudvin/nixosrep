{ self, ... }: {
  flake.nixosModules.system = {
    imports = [
      self.nixosModules.audio
      self.nixosModules.bluetooth
      self.nixosModules.boot
      self.nixosModules.cpu
      self.nixosModules.filesystems
      self.nixosModules.fonts
      self.nixosModules.fwupd
      self.nixosModules.greetd
      self.nixosModules.locale
      self.nixosModules.network
      self.nixosModules.nix
      self.nixosModules.packages
      self.nixosModules.polkit
      self.nixosModules.power
      self.nixosModules.radeon
      self.nixosModules.services
      self.nixosModules.steam
      self.nixosModules.systemd
      self.nixosModules.thunar
      self.nixosModules.users
      self.nixosModules.wireguard
      self.nixosModules.xdgPortal
    ];
  };
}
