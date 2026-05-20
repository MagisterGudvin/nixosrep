{ ... }: {
  flake.nixosModules.steam = { pkgs, ... }: {
    programs.steam = {
      enable = true;

      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      dedicatedServer.openFirewall = false;

      protontricks.enable = true;

      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    programs.gamemode.enable = true;

    # udev для Valve-железа: Steam Controller (USB/wireless dongle),
    # Index/Vive HMD, Steam Deck dock и т.п.
    hardware.steam-hardware.enable = true;

    # udev для не-Valve геймпадов: Xbox 360/One/Series, DualShock 4,
    # DualSense, Switch Pro. Без этого USB-подключение требует root.
    services.udev.packages = [ pkgs.game-devices-udev-rules ];

    environment.systemPackages = with pkgs; [
      zenity                     # модальные диалоги для wine/proton-installer'ов
      usbutils                   # lsusb для диагностики геймпадов/VR
    ];
  };
}
