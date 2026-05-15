{ ... }: {
  flake.homeModules.rofi = { pkgs, ... }: {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;

      plugins = with pkgs; [
        rofi-emoji
        rofi-calc
      ];

      theme = ./tokyonight-moon.rasi;

      extraConfig = {
        modi = "drun,run,window,emoji,calc";

        show-icons = true;
        icon-theme = "Papirus-Dark";

        display-drun = "  Apps";
        display-run = "  Run";
        display-window = "  Windows";
        display-emoji = "󰞅  Emoji";
        display-calc = "  Calc";

        drun-display-format = "{name}";

        kb-cancel = "Escape";
        matching = "fuzzy";
        sort = true;
        sorting-method = "fzf";
        scroll-method = 0;
        disable-history = false;
        hide-scrollbar = false;

        calc-command = "echo -n '{result}' | wl-copy";
        calc-result-clipboard = true;
      };
    };

    home.packages = with pkgs; [
      (writeShellScriptBin "rofi-launcher" ''
        rofi -show drun -show-icons
      '')
      (writeShellScriptBin "rofi-window" ''
        rofi -show window -show-icons
      '')
      (writeShellScriptBin "rofi-emoji-pick" ''
        rofi -show emoji
      '')
      (writeShellScriptBin "rofi-calc-pick" ''
        rofi -show calc -no-show-match -no-sort
      '')
      (writeShellScriptBin "rofi-runner" ''
        rofi -show run
      '')
    ];
  };
}
