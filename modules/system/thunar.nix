{ ... }: {
  flake.nixosModules.thunar = { pkgs, ... }: {
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        # «Извлечь сюда» / «Сжать в…» в контекстном меню. Использует
        # бинарь xarchiver (ставится отдельно в home.packages).
        thunar-archive-plugin
      ];
    };

    # gvfs нужен для монтирования съёмных носителей и сетевых шар из Thunar.
    services.gvfs.enable = true;

    # Поддержка иконок миниатюр (картинки/видео).
    services.tumbler.enable = true;

    # thunar-archive-plugin (TAP) ищет backend-скрипты (.tap) только
    # в $THUNAR_ARCHIVE_PLUGIN_HELPERS_PATH или в своём compile-time
    # libexecdir. В NixOS xarchiver и TAP лежат в разных
    # /nix/store/...prefix, и без перебития пути TAP не находит
    # xarchiver.tap — «Извлечь сюда» в Thunar падает с «не найдено
    # подходящего менеджера». environment.sessionVariables ставит
    # переменную через PAM в самом начале логина, поэтому niri и
    # любой запуск thunar (включая D-Bus activation) её наследуют.
    # NB: environment.variables — это только /etc/profile (shell),
    # для GUI-сессии нужна именно sessionVariables.
    environment.sessionVariables.THUNAR_ARCHIVE_PLUGIN_HELPERS_PATH =
      "${pkgs.xarchiver}/libexec/thunar-archive-plugin";
  };
}
