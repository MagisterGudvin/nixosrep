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
  };
}
