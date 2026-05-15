{ self, inputs, ... }: {
  flake.nixosModules.home = { pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs self; };

      users.gooblin = { ... }: {
        imports = [
          inputs.noctalia.homeModules.default

          self.homeModules.bash
          self.homeModules.deployFiles
          self.homeModules.fastfetch
          self.homeModules.fish
          self.homeModules.git
          self.homeModules.gtk
          self.homeModules.noctalia
          self.homeModules.obsidian
          self.homeModules.packages
          self.homeModules.rofi
          self.homeModules.shell
          self.homeModules.tools
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
