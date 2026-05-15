{ ... }: {
  flake.nixosModules.cpu = { ... }: {
    hardware.cpu.amd.updateMicrocode = true;

    # KVM для AMD (виртуализация).
    boot.kernelModules = [ "kvm-amd" ];
  };
}
