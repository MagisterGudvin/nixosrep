{ ... }: {
  flake.nixosModules.fwupd = { ... }: {
    # Прошивки через LVFS. Для Mechrevo вендор обычно не публикует, но BIOS/EC
    # части от AMD/чипсета прилетать могут.
    services.fwupd.enable = true;

    # fwupd-refresh.timer тикает раз в сутки и сразу после resume-from-hibernate.
    # После hibernate'а NetworkManager ещё не успевает поднять Wi-Fi, fwupdmgr
    # не может фетчить LVFS и валится: "Failed to start Refresh fwupd metadata".
    # network-online.target гарантирует, что NM подтвердил online-state, прежде
    # чем сервис стартанёт.
    systemd.services.fwupd-refresh = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
