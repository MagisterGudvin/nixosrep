{ ... }: {
  flake.nixosModules.bluetooth = { pkgs, ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        # Experimental=true заставляет bluez регистрировать BAP
        # (LE Audio), который требует kernel ISO Socket. У нас он
        # не экспортирован, и DisablePlugins=bap игнорируется —
        # warning "BAP requires ISO Socket" / "Failed to set default
        # system config" сыпался на каждый старт. LE Audio наушников
        # нет, Experimental ни для чего больше не нужен → выключаем.
        FastConnectable = true;
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
