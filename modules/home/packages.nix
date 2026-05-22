{ ... }: {
  flake.homeModules.packages = { pkgs, inputs, ... }: {
    home.packages = (with pkgs; [
      # --- Внешний вид / темы ---
      # Иконки Papirus / Adwaita / Hicolor / Breeze и курсор volantes
      # переехали в environment.systemPackages (modules/system/packages.nix),
      # чтобы попадать в XDG_DATA_DIRS niri-сессии.
      adw-gtk3                   # libadwaita-подобная тема для GTK3

      # --- Файловые менеджеры (TUI) ---
      yazi

      # --- Утилиты ---
      fastfetch
      bat                        # cat с подсветкой; на него алиасится `cat` в fish
      neovim                     # ну и `v` тоже алиасится сюда
      lazygit                    # `lg` алиас
      fzf                        # нужен fish-плагину fzf-fish, иначе каждый Tab ругается

      # --- Просмотр / медиа ---
      gthumb
      vlc
      zathura

      # --- Сеть / загрузки ---
      qbittorrent

      # --- Архиваторы ---
      xarchiver                  # GTK GUI, открывается через «Извлечь сюда» в thunar
      p7zip                      # .7z, .zip и большинство форматов
      unrar                      # распаковка .rar (unfree, проприетарный декодер)

      # --- Мессенджеры ---
      telegram-desktop

      # --- Экран / буфер обмена ---
      cliphist

      # --- Офис / редакторы / браузер ---
      libreoffice-fresh
      vscode-fhs
      brave

      # --- 3D / графика ---
      blockbench                 # low-poly 3D model editor (Minecraft и др.)

      # --- Игры / Steam-обвязка ---
      cemu                       # эмулятор Wii U

      # --- Wayland-десктоп: лаунчер ---
                                 # kitty приходит через programs.kitty (modules/home/kitty)

      # --- Скриншоты ---
      grim
      slurp
      swappy
      imagemagick
      libnotify

      # --- Крипто/CLI ---
      openssl
    ]) ++ [
      # Yandex Browser — нет ни в nixpkgs, ни на Flathub. Берём из
      # сторонней флейки miuirussia/yandex-browser.nix (распакованный
      # .deb + autoPatchelfHook). Кэш собран в yandex-browser-nix.cachix.org,
      # ключ подключён в modules/system/nix.nix. Обновлять браузер =
      # `nix flake update yandex-browser` (Yandex чистит старые билды
      # из репо, поэтому стоит держать lock свежим).
      inputs.yandex-browser.packages.${pkgs.stdenv.hostPlatform.system}.yandex-browser-stable
    ];

    # pkgs.vim кладёт gvim.desktop в системный профиль, но самой
    # gvim-GUI в этом vim-варианте нет — в лаунчере noctalia запись
    # видна, но клик молча падает. XDG-приоритет: ~/.local/share/applications/
    # перебивает /run/current-system/sw/share/applications/. Кладём свой
    # gvim.desktop с NoDisplay=true — запись исчезает из всех XDG-лаунчеров.
    xdg.desktopEntries.gvim = {
      name = "GVim";
      exec = "true";
      type = "Application";
      noDisplay = true;
    };


    # Дефолтный браузер для всех http/https/файл-открытий из других
    # приложений (Telegram-ссылка, кнопка «открыть в браузере» в noctalia
    # и т.п.). Без mimeApps.enable HM не пишет ~/.config/mimeapps.list,
    # и XDG берёт первый попавшийся .desktop с MimeType=text/html
    # (обычно brave из-за алфавитной сортировки).
    #
    # Для архивов и каталогов прибиваем дефолты к xarchiver / thunar,
    # потому что org.pwmt.zathura-cb.desktop (плагин zathura для
    # комиксов CBR/CBZ) объявляет жадный MimeType, включая обычные
    # application/zip, application/x-tar, application/x-7z-compressed,
    # и даже inode/directory.
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "yandex-browser.desktop";
        "application/xhtml+xml" = "yandex-browser.desktop";
        "x-scheme-handler/http" = "yandex-browser.desktop";
        "x-scheme-handler/https" = "yandex-browser.desktop";
        "x-scheme-handler/about" = "yandex-browser.desktop";
        "x-scheme-handler/unknown" = "yandex-browser.desktop";

        "inode/directory" = "thunar.desktop";

        "application/zip" = "xarchiver.desktop";
        "application/x-7z-compressed" = "xarchiver.desktop";
        "application/x-tar" = "xarchiver.desktop";
        "application/x-compressed-tar" = "xarchiver.desktop";
        "application/x-rar" = "xarchiver.desktop";
        "application/vnd.rar" = "xarchiver.desktop";
        "application/gzip" = "xarchiver.desktop";
        "application/x-bzip" = "xarchiver.desktop";
        "application/x-bzip2" = "xarchiver.desktop";
        "application/x-bzip-compressed-tar" = "xarchiver.desktop";
        "application/x-bzip2-compressed-tar" = "xarchiver.desktop";
        "application/x-xz" = "xarchiver.desktop";
        "application/x-xz-compressed-tar" = "xarchiver.desktop";
        "application/zstd" = "xarchiver.desktop";
        "application/x-zstd-compressed-tar" = "xarchiver.desktop";
      };
    };

    # BROWSER для CLI-тулзов (man с www-ссылками, `xdg-open` fallback,
    # fish-helper `__fish_print_help`).
    home.sessionVariables.BROWSER = "yandex-browser-stable";
  };
}
