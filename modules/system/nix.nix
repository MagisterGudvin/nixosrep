{ ... }: {
  flake.nixosModules.nix = { ... }: {
 nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://niri.cachix.org"
        "https://noctalia.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBo="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
      max-jobs = "auto";

      # Если substituter не отвечает (упал, недоступен по сети) — не
      # валить весь rebuild, а собрать из исходников.
      fallback = true;

      # Дохлые зеркала отрезаются быстро, не ждём 5-минутный таймаут.
      connect-timeout = 5;
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # steam, vscode, brave требуют unfree-лицензии — без этого флага
    # nixos-rebuild упадёт на eval с "Package X has an unfree license".
    nixpkgs.config.allowUnfree = true;

    # Платформа сборки. Если этого нет, NixOS ругается:
    #   "Neither nixpkgs.hostPlatform nor the legacy option nixpkgs.system
    #    has been set."
    # Свежий nixos-generate-config кладёт это в hardware-configuration.nix,
    # но если он старее — задаём здесь явно.
    nixpkgs.hostPlatform = "x86_64-linux";

    system.stateVersion = "25.11";
  };
}
