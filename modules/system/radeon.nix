{ ... }: {
  flake.nixosModules.radeon = { pkgs, ... }: {
    services.xserver.videoDrivers = [ "amdgpu" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        amdvlk
      ];
      extraPackages32 = with pkgs.driversi686Linux; [
        amdvlk
      ];
    };
  };
}
