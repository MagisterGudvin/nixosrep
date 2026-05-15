{ inputs, ... }: {
  flake.nixosModules.niri = { ... }: {
    imports = [ inputs.niri.nixosModules.niri ];

    # Сам конфиг niri живёт в home-module (modules/home/niri/default.nix).
    # Здесь только включаем niri на уровне системы — это поднимает
    # wayland-session, polkit-агент, xwayland-satellite, ставит бинарь
    # niri в PATH для всех юзеров.
    programs.niri.enable = true;
  };
}
