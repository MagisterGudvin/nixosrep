{ ... }: {
  flake.nixosModules.thunar = { pkgs, ... }: let
    # thunar-archive-plugin 0.6.0 захардкоживает путь к backend'ам
    # (.tap-скриптам) на этапе сборки — на свой собственный
    # $out/libexec/thunar-archive-plugin/. Env var, которая в старых
    # версиях позволяла этот путь переопределить, в 0.6.0 убрали.
    # В Debian/Arch xarchiver кладёт свой .tap в тот же /usr/libexec
    # и проблемы нет; в NixOS каждый пакет в своём /nix/store-prefix.
    # Пересобираем TAP с postInstall, который симлинкует xarchiver.tap
    # в его libexec — теперь оба видят друг друга в одном prefix'е.
    thunar-archive-plugin-with-xarchiver =
      pkgs.thunar-archive-plugin.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          mkdir -p $out/libexec/thunar-archive-plugin
          for tap in ${pkgs.xarchiver}/libexec/thunar-archive-plugin/*.tap; do
            ln -sv "$tap" $out/libexec/thunar-archive-plugin/
          done
        '';
      });
  in {
    programs.thunar = {
      enable = true;
      plugins = [
        # «Извлечь сюда» / «Сжать в…» в контекстном меню. Backend —
        # бинарь xarchiver (ставится в home.packages), .tap-скрипт
        # подложен в libexec через override выше.
        thunar-archive-plugin-with-xarchiver
      ];
    };

    # gvfs нужен для монтирования съёмных носителей и сетевых шар из Thunar.
    services.gvfs.enable = true;

    # Поддержка иконок миниатюр (картинки/видео).
    services.tumbler.enable = true;
  };
}
