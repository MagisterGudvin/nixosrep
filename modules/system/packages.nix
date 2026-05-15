{ ... }: {
  flake.nixosModules.packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      git
      vim
      curl
      wget
      htop
    ];
  };
}
