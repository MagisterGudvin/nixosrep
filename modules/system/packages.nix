{ ... }: {
  flake.nixosModules.packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Core utils
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
    ];
  };
}
