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

    # tuigreet с --remember-user-session пишет последний выбор в
    # /var/cache/tuigreet/state.toml. NixOS этот каталог сам не создаёт;
    # без него запись молча падает и на каждом логине сеанс приходится
    # выбирать заново. Владельцем должен быть пользователь greeter.
    systemd.tmpfiles.rules = [
      "d /var/cache/tuigreet 0755 greeter greeter - -"
    ];
  };
}
