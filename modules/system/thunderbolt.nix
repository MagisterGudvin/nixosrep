{ ... }: {
  flake.nixosModules.thunderbolt = { pkgs, ... }: {
    # boltd авторизует Thunderbolt/USB4-устройства согласно политике
    # IOMMU. Без него ядро видит подключённый dock/eGPU, но PCIe-туннель
    # остаётся в `Security: secure` без авторизации — устройство не
    # отображается на шине PCI и amdgpu его не подхватывает.
    #
    # boltctl enroll <uuid> --policy auto — запомнить устройство как
    # доверенное, авторизация при следующих подключениях идёт сама.
    services.hardware.bolt.enable = true;

    environment.systemPackages = with pkgs; [
      bolt                 # boltctl CLI
      dmidecode            # читать SMBIOS, в т.ч. инфу о USB4/TB-портах
    ];
  };
}
