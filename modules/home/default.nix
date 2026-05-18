{ self, inputs, ... }: {
  flake.nixosModules.home = { pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs self; };

      # При активации HM не должен падать, если в /home/<user>/.config
      # уже лежит файл, который он собирается записать (typical после
      # ручных правок или неудачной прошлой activation). Старая версия
      # сохраняется как foo.bak, а HM пишет свою.
      backupFileExtension = "bak";

      users.gooblin = { ... }: {
        imports = [
          inputs.noctalia.homeModules.default

          self.homeModules.bash
          self.homeModules.fastfetch
          self.homeModules.fish
          self.homeModules.git
          self.homeModules.gtk
          self.homeModules.kitty
          self.homeModules.niri
          self.homeModules.noctalia
          self.homeModules.obsidian
          self.homeModules.packages
          self.homeModules.rofi
          self.homeModules.tools
          self.homeModules.yandex-update-check
          self.homeModules.yazi
        ];

        home.username = "gooblin";
        home.homeDirectory = "/home/gooblin";
        home.stateVersion = "25.11";

        programs.home-manager.enable = true;
      };
    };
  };
}
