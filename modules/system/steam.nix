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
    programs.gamescope = {
      enable = true;
      # Без CAP_SYS_NICE gamescope не может выставлять realtime-приоритет
      # своим потокам: в логе сыпется "No CAP_SYS_NICE, falling back to
      # regular-priority compute and threads. Performance will be affected."
      capSysNice = true;
      # Дефолтные аргументы — применяются ко всем запускам gamescope
      # (в т.ч. через параметры запуска Steam). --expose-wayland нужен,
      # чтобы внутри gamescope wayland-нативные приложения могли
      # коммуницировать с парент-композитором (niri) — без этого на
      # niri gamescope-сурфейс не маппится как toplevel.
      args = [
        "--expose-wayland"
      ];
    };

    # udev для Valve-железа: Steam Controller (USB/wireless dongle),
    # Index/Vive HMD, Steam Deck dock и т.п.
    hardware.steam-hardware.enable = true;

    # udev для не-Valve геймпадов: Xbox 360/One/Series, DualShock 4,
    # DualSense, Switch Pro. Без этого USB-подключение требует root.
    services.udev.packages = [ pkgs.game-devices-udev-rules ];

    environment.systemPackages = with pkgs; [
      mangohud
      zenity                     # модальные диалоги для wine/proton-installer'ов
      usbutils                   # lsusb для диагностики геймпадов/VR
    ];
  };
}
