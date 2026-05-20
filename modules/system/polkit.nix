{ ... }: {
  flake.nixosModules.polkit = { pkgs, ... }: {
    security.polkit.enable = true;

    environment.systemPackages = [ pkgs.hyprpolkitagent ];

    # services.hyprpolkitagent появилось в nixpkgs относительно недавно и
    # есть не во всех каналах — поднимаем agent сами как systemd user service,
    # привязанный к graphical-session.target. Стартует вместе с niri.
    systemd.user.services.hyprpolkitagent = {
      description = "Hyprland PolicyKit Authentication Agent";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Restart = "on-failure";
      };
    };

    # niri-flake тащит свой polkit-kde-authentication-agent в составе
    # niri-flake-polkit.service. Он стартует, видит уже занятый DBus-
    # subject и пять раз падает с "An authentication agent already
    # exists" → systemd упирается в start-limit-hit и пишет ERROR.
    # У нас уже есть hyprpolkitagent выше, второй агент не нужен.
    systemd.user.services.niri-flake-polkit.enable = false;
  };
}
