{ ... }: {
  flake.nixosModules.thunar = { ... }: {
    programs.thunar = {
      enable = true;
      plugins = [ ];
    };

    # gvfs нужен для монтирования съёмных носителей и сетевых шар из Thunar.
    services.gvfs.enable = true;

    # Поддержка иконок миниатюр (картинки/видео).
    services.tumbler.enable = true;
  };
}
