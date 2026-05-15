{ ... }: {
  flake.nixosModules.power = { pkgs, ... }: {
    services.power-profiles-daemon.enable = true;

    # UPower — D-Bus сервис, который экспортирует состояние батареи.
    # Без него noctalia/любой бар не видит батарею, и `upower -i` пуст.
    services.upower.enable = true;

    # acpid обрабатывает события lid-close, power-key, AC plug на уровне
    # ядра (доп. поверх systemd-logind для случаев, когда нужно ловить
    # сырые ACPI-события).
    services.acpid.enable = true;

    # `programs.light` удалён из nixpkgs (upstream unmaintained).
    # Используем brightnessctl + правило udev из hardware.acpilight,
    # чтобы юзер в группе `video` мог менять яркость без sudo.
    hardware.acpilight.enable = true;

    environment.systemPackages = [ pkgs.brightnessctl ];

    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandlePowerKey = "suspend";
      IdleAction = "ignore";
    };

    powerManagement.enable = true;
  };
}
