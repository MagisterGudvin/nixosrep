{ ... }: {
  flake.nixosModules.systemPackages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      git
      vim
      curl
      wget
      htop
    ];
  };
}
