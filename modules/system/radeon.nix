{ ... }: {
  flake.nixosModules.radeon = { pkgs, ... }: {
    # amdgpu в initrd — ранний KMS, плавный переход bootloader → console.
    boot.initrd.kernelModules = [ "amdgpu" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      # RADV (Vulkan) и radeonsi (OpenGL) идут в составе mesa.
      extraPackages = with pkgs; [
        mesa
        libva
        libva-utils
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
