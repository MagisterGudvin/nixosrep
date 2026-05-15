{ ... }: {
  flake.nixosModules.forzaHardware = { ... }: {
    # NVMe + USB/SD для root-mount из initrd.
    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];
  };
}
