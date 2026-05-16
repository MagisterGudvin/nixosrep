{ ... }: {
  flake.nixosModules.services = { pkgs, ... }: {
    services.openssh.enable = false;
    services.printing.enable = false;

    # dconf нужен для того, чтобы GTK-приложения и xdg-desktop-portal
    # подхватывали иконки/темы/курсор. Без dconf gtk.iconTheme от HM
    # пишет ~/.config/gtk-3.0/settings.ini, но не задаёт gsettings —
    # часть приложений (Files-like, libadwaita-based) их игнорируют.
    programs.dconf.enable = true;

    # nixpkgs кладёт gschema-файлы не в share/glib-2.0/schemas/, а в
    # share/gsettings-schemas/<pkg-name>/glib-2.0/schemas/. Поэтому
    # gsettings, который ищет под XDG_DATA_DIRS/glib-2.0/schemas/,
    # без явного хинта их не находит — выдаёт «Схемы не установлены».
    # Добавляем эти пакетные пути в XDG_DATA_DIRS глобально.
    environment.sessionVariables = {
      XDG_DATA_DIRS = [
        "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
        "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
        "${pkgs.glib}/share/gsettings-schemas/${pkgs.glib.name}"
      ];
    };
  };
}
