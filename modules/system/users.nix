{ ... }: {
  flake.nixosModules.users = { pkgs, ... }: {
    users.users.gooblin = {
      isNormalUser = true;
      description = "gooblin";
      extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
      shell = pkgs.bash;
    };
  };
}
