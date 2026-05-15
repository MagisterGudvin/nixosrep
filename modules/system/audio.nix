{ ... }: {
  flake.nixosModules.audio = { pkgs, ... }: {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    # wpctl приходит из wireplumber; явно кладём в PATH,
    # чтобы niri-spawn (`sh -c "wpctl …"`) находил его.
    environment.systemPackages = [ pkgs.wireplumber ];
  };
}
