{ ... }: {
  flake.nixosModules.greetd = { pkgs, config, ... }: {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --cmd niri-session";
          user = "greeter";
        };
      };
    };
  };
}
