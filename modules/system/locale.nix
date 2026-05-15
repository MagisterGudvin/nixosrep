{ ... }: {
  flake.nixosModules.locale = { pkgs, ... }: {
    time.timeZone = "Europe/Moscow";

    i18n.defaultLocale = "ru_RU.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_IDENTIFICATION = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };

    console = {
      keyMap = "us";
      # Terminus с полным Unicode — нужен, чтобы tuigreet и системные
      # сообщения в tty/VT корректно рендерили кириллицу
      # (дефолтный lat9w-16 кириллических глифов не содержит).
      font = "ter-v22n";
      packages = [ pkgs.terminus_font ];
      earlySetup = true;
    };
  };
}
