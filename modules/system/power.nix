{ ... }: {
  flake.nixosModules.power = { ... }: {
    # power-profiles-daemon хорошо живёт с amd_pstate и переключением EPP.
    # Конфликтует с TLP — поэтому оба разом не включать.
    services.power-profiles-daemon.enable = true;

    # Управление яркостью без sudo (работает с brightnessctl).
    programs.light.enable = true;

    # Закрытие крышки → suspend; кнопка питания → suspend.
    services.logind = {
      lidSwitch = "suspend";
      lidSwitchExternalPower = "suspend";
      extraConfig = ''
        HandlePowerKey=suspend
        IdleAction=ignore
      '';
    };

    # Поддержка hibernate — раздел swap уже сконфигурирован в filesystems.nix.
    powerManagement.enable = true;
  };
}
