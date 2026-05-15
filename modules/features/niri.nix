{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  perSystem = { pkgs, lib, ... }:
    let
      noctalia = lib.getExe inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      term = "${lib.getExe pkgs.foot} fish";
      blank = _: {};
      shotDir = "$HOME/Pictures/Screenshots";
      mkShot = mode: ''
        mkdir -p ${shotDir}
        ${pkgs.grim}/bin/grim ${
          if mode == "area"
          then "-g \"$(${pkgs.slurp}/bin/slurp)\""
          else ""
        } - | tee ${shotDir}/$(date +%Y-%m-%d_%H-%M-%S).png | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png
      '';
    in {
      packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        settings = {
          spawn-at-startup = [
            noctalia
          ];

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          input.keyboard.xkb.layout = "us,ru";

          layout = {
            gaps = 5;
            preset-column-widths = [
              { proportion = 0.5; }
              { proportion = 0.75; }
              { proportion = 1.0; }
            ];
          };

          binds = {
            # --- Apps ---
            "Mod+Return".spawn-sh = term;
            "Mod+E".spawn-sh = term;
            "Mod+B".spawn-sh = lib.getExe pkgs.brave;
            "Mod+Q".spawn-sh = "${pkgs.xfce.thunar}/bin/thunar";
            "Mod+Space".spawn-sh = "${noctalia} ipc call launcher toggle";
            "Mod+Shift+Space".spawn-sh = "${noctalia} ipc call controlCenter toggle";
            "Mod+W".spawn-sh = lib.getExe pkgs.waypaper;
            "Mod+V".spawn-sh = "cliphist list | rofi -dmenu | cliphist decode | wl-copy";
            "Mod+S".spawn-sh = mkShot "area";
            "Mod+Shift+S".spawn-sh = mkShot "screen";
            "Mod+Escape".spawn-sh = "${noctalia} ipc call sessionMenu toggle";

            # --- Window Management ---
            "Mod+C".close-window = blank;
            "Mod+F".maximize-column = blank;
            "Mod+Shift+F".fullscreen-window = blank;
            "Mod+T".toggle-window-floating = blank;
            "Mod+O".toggle-overview = blank;
            "Mod+R".switch-preset-column-width = blank;

            "Mod+H".focus-column-left = blank;
            "Mod+L".focus-column-right = blank;
            "Mod+J".focus-window-down = blank;
            "Mod+K".focus-window-up = blank;

            "Mod+Ctrl+H".move-column-left = blank;
            "Mod+Ctrl+L".move-column-right = blank;
            "Mod+Ctrl+J".move-window-down = blank;
            "Mod+Ctrl+K".move-window-up = blank;

            "Mod+Shift+Left".set-column-width = "-10%";
            "Mod+Shift+Right".set-column-width = "+10%";
            "Mod+Shift+Up".set-window-height = "-10%";
            "Mod+Shift+Down".set-window-height = "+10%";

            "Mod+1".focus-workspace = 1;
            "Mod+2".focus-workspace = 2;
            "Mod+3".focus-workspace = 3;
            "Mod+4".focus-workspace = 4;
            "Mod+5".focus-workspace = 5;
            "Mod+6".focus-workspace = 6;
            "Mod+7".focus-workspace = 7;
            "Mod+8".focus-workspace = 8;
            "Mod+9".focus-workspace = 9;
            "Mod+Shift+1".move-column-to-workspace = 1;
            "Mod+Shift+2".move-column-to-workspace = 2;
            "Mod+Shift+3".move-column-to-workspace = 3;
            "Mod+Shift+4".move-column-to-workspace = 4;
            "Mod+Shift+5".move-column-to-workspace = 5;
            "Mod+Shift+6".move-column-to-workspace = 6;
            "Mod+Shift+7".move-column-to-workspace = 7;
            "Mod+Shift+8".move-column-to-workspace = 8;
            "Mod+Shift+9".move-column-to-workspace = 9;

            # --- System ---
            "Mod+Alt+L".spawn-sh = "${noctalia} ipc call lockScreen toggle";
            "Mod+Shift+L".spawn-sh = "${noctalia} ipc call lockScreen toggle";
            "Mod+Shift+M".quit = blank;
            "Mod+Shift+B".spawn-sh = "${noctalia} ipc call bar toggle";
            "Mod+Shift+N".spawn-sh = "${noctalia} ipc call nightLight toggle";

            # --- Media (работают и на lock-экране) ---
            "Mod+P" = { spawn-sh = "playerctl play-pause"; allow-when-locked = true; };
            "Mod+comma" = { spawn-sh = "playerctl previous"; allow-when-locked = true; };
            "Mod+period" = { spawn-sh = "playerctl next"; allow-when-locked = true; };

            "XF86AudioPlay" = { spawn-sh = "playerctl play-pause"; allow-when-locked = true; };
            "XF86AudioNext" = { spawn-sh = "playerctl next"; allow-when-locked = true; };
            "XF86AudioPrev" = { spawn-sh = "playerctl previous"; allow-when-locked = true; };

            "XF86AudioRaiseVolume" = { spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"; allow-when-locked = true; };
            "XF86AudioLowerVolume" = { spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; allow-when-locked = true; };
            "XF86AudioMute"        = { spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; allow-when-locked = true; };
            "XF86AudioMicMute"     = { spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; allow-when-locked = true; };

            "XF86MonBrightnessUp"   = { spawn-sh = "brightnessctl set 5%+"; allow-when-locked = true; };
            "XF86MonBrightnessDown" = { spawn-sh = "brightnessctl set 5%-"; allow-when-locked = true; };
          };
        };
      };
    };
}
