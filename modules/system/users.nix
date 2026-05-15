{ ... }: {
  flake.nixosModules.users = { pkgs, ... }: {
    programs.fish.enable = true;

    users.users.gooblin = {
      isNormalUser = true;
      description = "gooblin";
      extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
      shell = pkgs.fish;
    };
  };
}
