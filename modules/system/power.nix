{ ... }: {
  flake.nixosModules.power = { ... }: {
    services.power-profiles-daemon.enable = true;

    programs.light.enable = true;

    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandlePowerKey = "suspend";
      IdleAction = "ignore";
    };

    powerManagement.enable = true;
  };
}
