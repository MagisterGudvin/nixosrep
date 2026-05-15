{ ... }: {
  flake.homeModules.shell = { pkgs, ... }: {
    programs.bash = {
      enable = true;
      shellAliases = {
        ll = "ls -la";
      };
    };

    programs.starship.enable = true;
  };
}
