{ ... }: {
  flake.nixosModules.fwupd = { ... }: {
    # Прошивки через LVFS. Для Mechrevo вендор обычно не публикует, но BIOS/EC
    # части от AMD/чипсета прилетать могут.
    services.fwupd.enable = true;
  };
}
