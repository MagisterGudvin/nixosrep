{ ... }: {
  flake.homeModules.packages = { pkgs, ... }: {
    home.packages = with pkgs; [
      # --- Внешний вид / темы ---
      # Иконки Papirus / Adwaita / Hicolor / Breeze и курсор volantes
      # переехали в environment.systemPackages (modules/system/packages.nix),
      # чтобы попадать в XDG_DATA_DIRS niri-сессии.
      awww                       # просмотр и установка GTK/иконок/курсоров одной командой
      adw-gtk3                   # libadwaita-подобная тема для GTK3
      waypaper                   # GUI для выбора обоев (swww/hyprpaper)

      # --- Системные апплеты / статус ---
      swaynotificationcenter     # swaync, демон уведомлений + swaync-client
      nwg-drawer                 # лаунчер в стиле GNOME app-drawer
      nwg-menu                   # меню для nwg-drawer / nwg-panel

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
      mpv
      cassette                   # клиент Яндекс.Музыки (GTK4)
      zathura

      # --- Экран / буфер обмена ---
      wlr-randr
      cliphist

      # --- Офис / редакторы / браузер ---
      libreoffice-fresh
      vscode-fhs
      brave

      # --- 3D / графика ---
      blockbench                 # low-poly 3D model editor (Minecraft и др.)

      # --- Wayland-десктоп: лаунчер ---
                                 # kitty приходит через programs.kitty (modules/home/kitty)
                                 # rofi приходит через programs.rofi  (modules/home/rofi)

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
