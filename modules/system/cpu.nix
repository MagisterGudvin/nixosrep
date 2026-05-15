{ ... }: {
  flake.nixosModules.cpu = { ... }: {
    hardware.cpu.amd.updateMicrocode = true;
  };
}
