{ ... }: {
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji

        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.hack
      ];
    };
  };
}
