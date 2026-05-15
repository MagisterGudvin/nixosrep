{ ... }: {
  flake.nixosModules.greetd = { pkgs, ... }: {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks --sessions /run/current-system/sw/share/wayland-sessions --cmd niri-session";
          user = "greeter";
        };
      };
    };
  };
}
