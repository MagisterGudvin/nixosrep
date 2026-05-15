{ ... }: {
  flake.nixosModules.power = { pkgs, ... }: {
    services.power-profiles-daemon.enable = true;

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
