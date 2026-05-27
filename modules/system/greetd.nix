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

    # /var/cache/tuigreet нужен для --remember-user-session (tuigreet
    # пишет туда state.toml). Раньше NixOS-модуль greetd этот каталог
    # не создавал — приходилось добавлять вручную через
    # systemd.tmpfiles.rules. В свежем nixpkgs (см. /etc/tmpfiles.d/
    # 00-nixos.conf) каталог уже создаётся самим модулем, поэтому
    # ручное правило убрано — иначе systemd-tmpfiles ругается на
    # "Duplicate line".

    # greetd PAM-стек по умолчанию тянет pam_gnome_keyring.so для
    # автоматической разблокировки keyring при входе. У нас keyring
    # не настроен, поэтому модуль пишет в журнал "gkr-pam: unable to
    # locate daemon control file" на каждой попытке логина. Отключаем —
    # PAM для greetd просто не пытается это сделать.
    security.pam.services.greetd.enableGnomeKeyring = false;
  };
}
