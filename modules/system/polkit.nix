{ ... }: {
  flake.nixosModules.polkit = { ... }: {
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
}
