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
      term = lib.getExe pkgs.foot;
      blank = _: {};
    in {
      packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        settings = {
          spawn-at-startup = [
            noctalia
          ];

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          input.keyboard.xkb.layout = "us,ru";

          layout.gaps = 5;

          binds = {
            # --- Запуск приложений ---
            "Mod+Return".spawn-sh = term;
            "Mod+T".spawn-sh = term;
            "Mod+D".spawn-sh = "rofi-launcher";
            "Mod+W".spawn-sh = "rofi-window";
            "Mod+E".spawn-sh = "rofi-emoji-pick";
            "Mod+C".spawn-sh = "rofi-calc-pick";
            "Mod+S".spawn-sh = "${noctalia} ipc call launcher toggle";
            "Mod+V".spawn-sh = "cliphist list | rofi -dmenu | cliphist decode | wl-copy";
            "Print".spawn-sh = "${pkgs.bash}/bin/bash $HOME/.local/bin/niri-screenshot.sh";

            # --- Окна ---
            "Mod+Q".close-window = blank;
            "Mod+F".maximize-column = blank;
            "Mod+Shift+F".fullscreen-window = blank;
            "Mod+Space".switch-preset-column-width = blank;
            "Mod+Ctrl+F".center-column = blank;

            # --- Фокус (vim-style) ---
            "Mod+H".focus-column-left = blank;
            "Mod+L".focus-column-right = blank;
            "Mod+J".focus-window-down = blank;
            "Mod+K".focus-window-up = blank;
            "Mod+Left".focus-column-left = blank;
            "Mod+Right".focus-column-right = blank;
            "Mod+Down".focus-window-down = blank;
            "Mod+Up".focus-window-up = blank;

            # --- Перемещение окна ---
            "Mod+Shift+H".move-column-left = blank;
            "Mod+Shift+L".move-column-right = blank;
            "Mod+Shift+J".move-window-down = blank;
            "Mod+Shift+K".move-window-up = blank;

            # --- Воркспейсы ---
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
            "Mod+Page_Down".focus-workspace-down = blank;
            "Mod+Page_Up".focus-workspace-up = blank;
            "Mod+Shift+Page_Down".move-column-to-workspace-down = blank;
            "Mod+Shift+Page_Up".move-column-to-workspace-up = blank;

            # --- Громкость / яркость / медиа ---
            "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86AudioMute".spawn-sh        = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86AudioMicMute".spawn-sh     = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            "XF86MonBrightnessUp".spawn-sh   = "brightnessctl set 5%+";
            "XF86MonBrightnessDown".spawn-sh = "brightnessctl set 5%-";
            "XF86AudioPlay".spawn-sh = "playerctl play-pause";
            "XF86AudioNext".spawn-sh = "playerctl next";
            "XF86AudioPrev".spawn-sh = "playerctl previous";

            # --- Системные ---
            "Mod+Shift+E".quit = blank;
            "Mod+Shift+R".spawn-sh = "${pkgs.systemd}/bin/systemctl --user restart niri.service || true";
          };
        };
      };
    };
}
