{ ... }: {
  flake.nixosModules.bluetooth = { pkgs, ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Experimental = true;
        FastConnectable = true;
        # BAP (Bluetooth LE Audio Basic Audio Profile) требует kernel-
        # модуль ISO Socket, который в нашей сборке ядра не
        # экспортирован. Поскольку у нас нет LE Audio наушников,
        # просто выключаем плагин — пропадёт спам "BAP requires ISO
        # Socket" / "Failed to set default system config" в логе.
        DisablePlugins = "bap";
      };
    };

    # blueman не нужен: noctalia-bar содержит свой Bluetooth-виджет,
    # который ходит в bluez через D-Bus напрямую. Отключение blueman:
    #   - убирает warning "blueman-applet.service: more than one ExecStart"
    #   - сокращает dbus duplicate-name спам (org.blueman.Mechanism / .Applet)
    services.blueman.enable = false;

    environment.systemPackages = with pkgs; [
      bluez
      bluez-tools
    ];
  };
}
