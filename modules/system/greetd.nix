{ ... }: {
  flake.nixosModules.greetd = { pkgs, ... }: {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks --sessions /run/current-system/sw/share/wayland-sessions";
          user = "greeter";
        };
      };
    };
  };
}
