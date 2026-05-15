{ self, inputs, ... }: {
  flake.nixosModules.home = { pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs self; };

      users.myUser = { ... }: {
        imports = [
          self.homeModules.shell
          self.homeModules.git
          self.homeModules.packages
        ];

        home.username = "myUser";
        home.homeDirectory = "/home/myUser";
        home.stateVersion = "25.11";

        programs.home-manager.enable = true;
      };
    };
  };
}
