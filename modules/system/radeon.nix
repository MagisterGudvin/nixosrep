{ ... }: {
  flake.nixosModules.radeon = { pkgs, ... }: {
    services.xserver.videoDrivers = [ "modesetting" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        mesa
        libva-vdpau-driver
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.mesa
      ];
    };

    environment.variables = {
      AMD_VULKAN_ICD = "RADV";
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";
    };
  };
}
