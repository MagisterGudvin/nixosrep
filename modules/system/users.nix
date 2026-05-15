{ ... }: {
  flake.nixosModules.users = { pkgs, ... }: {
    users.users.myUser = {
      isNormalUser = true;
      description = "myUser";
      extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
      shell = pkgs.bash;
    };
  };
}
