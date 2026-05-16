{ inputs, ... }: {
  flake.nixosModules.niri = { ... }: {
    imports = [ inputs.niri.nixosModules.niri ];

    # Сам конфиг niri живёт в home-module (modules/home/niri/default.nix).
    # Здесь только включаем niri на уровне системы — это поднимает
    # wayland-session, polkit-агент, xwayland-satellite, ставит бинарь
    # niri в PATH для всех юзеров.
    #
    # programs.niri.package НЕ переопределяем — пусть niri-flake
    # подсовывает свою закреплённую сборку, которая лежит в niri.cachix.org
    # уже прогнанная через тесты. Override на pkgs.niri.overrideAttrs
    # заставлял собирать nixpkgs-версию из исходников, и в ней наблюдался
    # регресс с встроенной клавиатурой ноутбука.
    programs.niri.enable = true;
  };
}
