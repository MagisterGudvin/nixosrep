{ ... }: {
  flake.homeModules.git = { ... }: {
    programs.git = {
      enable = true;
      userName = "myUser";
      userEmail = "myUser@example.com";
    };
  };
}
