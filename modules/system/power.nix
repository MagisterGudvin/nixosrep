{ ... }: {
  flake.nixosModules.power = { pkgs, ... }: {
    services.power-profiles-daemon.enable = true;

    # UPower — D-Bus сервис, который экспортирует состояние батареи.
    # Без него noctalia/любой бар не видит батарею, и `upower -i` пуст.
    # Дополнительно настраиваем автогибернацию при критическом заряде —
    # 5% триггер вместо дефолтного suspend-and-hope.
    services.upower = {
      enable = true;
      criticalPowerAction = "Hibernate";
      percentageLow = 15;
      percentageCritical = 5;
      percentageAction = 3;
    };

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
      # Закрыл крышку / нажал power-key → сначала suspend (RAM-сон,
      # просыпается мгновенно), а через 30 мин если не разбудили —
      # автоматически перешло в hibernate (на диск, питание 0).
      # Балансирует скорость пробуждения и сохранность батареи.
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
      HandlePowerKey = "suspend-then-hibernate";
      IdleAction = "ignore";
    };

    # Через сколько времени suspend-then-hibernate перейдёт из RAM-сна
    # в диск. По умолчанию 2 часа — для ноута это многовато, при
    # дороге/в сумке батарея заметно подсаживается.
    # Это [Sleep]-секция /etc/systemd/sleep.conf, не logind!
    systemd.sleep.settings.Sleep.HibernateDelaySec = "30min";

    powerManagement.enable = true;
  };
}
