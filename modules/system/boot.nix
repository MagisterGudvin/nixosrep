{ ... }: {
  flake.nixosModules.boot = { pkgs, ... }: {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = 3;

    # Свежее ядро для нормальной поддержки Radeon 780M (RDNA3, gfx1103)
    # и amd_pstate на Hawk Point (Ryzen 8000-серия).
    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.kernelParams = [
      # CPPC-управление частотой через amd_pstate (active = драйвер сам выбирает freq).
      "amd_pstate=active"
      # Глубокий S3-sleep (на современных AMD-ноутах часто лучше s2idle).
      "mem_sleep_default=deep"
    ];

    # Закрытые прошивки (Wi-Fi, BT, GPU microcode и т.д.).
    hardware.enableRedistributableFirmware = true;
    hardware.enableAllFirmware = true;
  };
}
