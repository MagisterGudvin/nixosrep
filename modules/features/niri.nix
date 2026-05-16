{ inputs, ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    imports = [ inputs.niri.nixosModules.niri ];

    # Сам конфиг niri живёт в home-module (modules/home/niri/default.nix).
    # Здесь только включаем niri на уровне системы — это поднимает
    # wayland-session, polkit-агент, xwayland-satellite, ставит бинарь
    # niri в PATH для всех юзеров.
    programs.niri.enable = true;

    # Тесты niri в Rust используют EGL/GL, которые в nix-build sandbox
    # ломаются (SIGABRT на egl_init). Отключаем — нам нужен только бинарь.
    # niri.cachix.org обычно отдаёт прибилженный артефакт, но если
    # подключение timeout-ится, сборка падает на тестах.
    programs.niri.package = pkgs.niri.overrideAttrs (old: {
      doCheck = false;
      doInstallCheck = false;
    });
  };
}
