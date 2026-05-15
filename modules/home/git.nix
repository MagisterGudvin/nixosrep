{ ... }: {
  flake.homeModules.git = { ... }: {
    programs.git = {
      enable = true;
      userName = "gooblin";
      userEmail = "gooblin@nixos.local";
    };
  };
}
