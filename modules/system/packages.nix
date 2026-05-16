{ ... }: {
  flake.nixosModules.packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
    wget
    git
    vim
    curl
    unzip
    zip
    btop
    python3
    ffmpeg
    pciutils
    docker-compose
    wl-clipboard
    brightnessctl
    playerctl
    xdg-utils
    tree
    ntfs3g
    hyprpolkitagent
    visidata
    jdk21
    glib                       # gsettings CLI для проверки/правки темы из терминала

    # Иконки/курсоры — ставим на уровне системы, чтобы они оказались
    # в /run/current-system/sw/share, который GTK/Qt всегда видят
    # через XDG_DATA_DIRS. В home.packages их класть бессмысленно
    # для приложений, запускаемых из niri (env-у user-profile там нет).
    papirus-icon-theme
    adwaita-icon-theme
    hicolor-icon-theme
    kdePackages.breeze-icons
    volantes-cursors
    ];
  };
}
