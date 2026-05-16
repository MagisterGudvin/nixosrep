{ ... }: {
  flake.nixosModules.services = { ... }: {
    services.openssh.enable = false;
    services.printing.enable = false;

    # dconf нужен для того, чтобы GTK-приложения и xdg-desktop-portal
    # подхватывали иконки/темы/курсор. Без dconf gtk.iconTheme от HM
    # пишет ~/.config/gtk-3.0/settings.ini, но не задаёт gsettings —
    # часть приложений (Files-like, libadwaita-based) их игнорируют.
    programs.dconf.enable = true;
  };
}
