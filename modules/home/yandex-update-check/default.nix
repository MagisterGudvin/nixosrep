{ ... }: {
  flake.homeModules.yandex-update-check = { pkgs, ... }: {
    # Раз в неделю спрашиваем github-api: совпадает ли rev из
    # flake.lock с текущим master в miuirussia/yandex-browser.nix.
    # Если нет — notify-send в noctalia/swaync. Сам lock не трогаем,
    # rebuild не запускаем — это императивные действия и пусть юзер
    # делает их сам, когда захочет.
    systemd.user.services.yandex-browser-update-check = {
      Unit = {
        Description = "Check upstream yandex-browser.nix flake for new commits";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = toString (pkgs.writeShellScript "yandex-browser-update-check" ''
          set -eu
          LOCK="$HOME/nixosrep/flake.lock"
          [ -f "$LOCK" ] || exit 0

          LOCKED=$(${pkgs.jq}/bin/jq -r '.nodes."yandex-browser".locked.rev' "$LOCK")
          LATEST=$(${pkgs.curl}/bin/curl -fsSL --max-time 30 \
            https://api.github.com/repos/miuirussia/yandex-browser.nix/commits/master \
            | ${pkgs.jq}/bin/jq -r '.sha' || echo "")

          if [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; then
            # GitHub недоступен / rate-limit — молча выходим, попробуем
            # на следующей неделе.
            exit 0
          fi

          if [ "$LOCKED" != "$LATEST" ]; then
            ${pkgs.libnotify}/bin/notify-send \
              -a "Yandex Browser" \
              -i "web-browser" \
              -u normal \
              "Yandex Browser: обновление" \
              "Доступна новая версия флейка.\nЗапусти:\ncd ~/nixosrep && nix flake update yandex-browser && sudo nixos-rebuild switch --flake .#forza"
          fi
        '');
      };
    };

    systemd.user.timers.yandex-browser-update-check = {
      Unit.Description = "Weekly check for Yandex Browser flake updates";
      Timer = {
        OnCalendar = "weekly";
        # Если ноут спал в момент срабатывания — стрельнуть сразу
        # после пробуждения. Иначе уведомление получишь только через
        # неделю.
        Persistent = true;
        # Размазать запуск по часу, чтобы не упираться в github
        # rate-limit одновременно с сотней других пользователей.
        RandomizedDelaySec = "1h";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
