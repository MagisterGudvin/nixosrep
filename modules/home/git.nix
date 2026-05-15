{ ... }: {
  flake.homeModules.git = { ... }: {
    programs.git = {
      enable = true;
      settings.user.name = "gooblin";
      settings.user.email = "gooblin@nixos.local";
    };
  };
}
