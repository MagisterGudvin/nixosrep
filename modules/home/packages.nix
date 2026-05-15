{ ... }: {
  flake.homeModules.packages = { pkgs, ... }: {
    home.packages = with pkgs; [
      # --- Внешний вид / темы ---
      awww                       # просмотр и установка GTK/иконок/курсоров одной командой
      papirus-icon-theme         # основной набор иконок Papirus-Dark
      hicolor-icon-theme         # обязательный fallback по freedesktop spec
      adwaita-icon-theme         # дефолтные иконки GNOME — fallback для GTK
      kdePackages.breeze-icons   # дефолтные иконки KDE/Qt — fallback для Qt
      adw-gtk3                   # libadwaita-подобная тема для GTK3
      waypaper                   # GUI для выбора обоев (swww/hyprpaper)

      # --- Системные апплеты / статус ---
      swaynotificationcenter     # swaync, демон уведомлений + swaync-client
      nwg-drawer                 # лаунчер в стиле GNOME app-drawer
      nwg-menu                   # меню для nwg-drawer / nwg-panel

      # --- Файловые менеджеры (TUI) ---
      lf
      yazi

      # --- Утилиты ---
      fastfetch

      # --- Просмотр / медиа ---
      gthumb
      mpv
      cassette                   # клиент Яндекс.Музыки (GTK4)
      zathura

      # --- БД и инструменты разработки БД ---
      postgresql_17
      prisma-engines

      # --- Экран / буфер обмена ---
      wlr-randr
      cliphist

      # --- Офис / редакторы / браузер ---
      libreoffice-fresh
      vscode-fhs
      brave

      # --- 3D / графика ---
      blockbench                 # low-poly 3D model editor (Minecraft и др.)

      # --- Wayland-десктоп: терминал, лаунчер ---
      foot                       # терминал по умолчанию (Mod+Return/Mod+E)
                                 # rofi приходит через programs.rofi.enable (modules/home/rofi)

      # --- Скриншоты ---
      grim
      slurp
      swappy
      grimblast
      imagemagick
      libnotify

      # --- Крипто/CLI ---
      openssl
    ];
  };
}
