{ ... }: {
  flake.homeModules.fish = { pkgs, ... }: {
    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        set fish_greeting ""

        # Монохромная подсветка под ч/б обои. ANSI 232..255 — серая
        # рампа от чёрного к белому, никаких цветных акцентов.
        set -g fish_color_normal 252
        set -g fish_color_command 254 --bold
        set -g fish_color_param 250
        set -g fish_color_quote 247
        set -g fish_color_redirection 244
        set -g fish_color_comment 240
        set -g fish_color_error 255 --bold
        set -g fish_color_search_match --background=238
        set -g fish_color_selection --background=238
        set -g fish_color_autosuggestion 242
        set -g fish_color_operator 252
        set -g fish_color_escape 246
        set -g fish_color_cwd 254
        set -g fish_color_user 252
        set -g fish_color_host 248
        set -g fish_pager_color_progress 240
        set -g fish_pager_color_completion 248
        set -g fish_pager_color_description 244
        set -g fish_pager_color_prefix 252 --bold

        zoxide init fish | source
        atuin init fish --disable-up-arrow | source
        starship init fish | source

        fastfetch
      '';

      shellAliases = {
        ls = "eza --icons";
        ll = "eza -la --icons --git";
        lt = "eza --tree --icons";
        cat = "bat";
        v = "nvim";
        lg = "lazygit";

        ff = "clear && fastfetch";
        fm = "yazi";
        cdlw = "cd /run/media/gooblin/lw";
      };

      plugins = [
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
        {
          name = "autopair";
          src = pkgs.fishPlugins.autopair.src;
        }
      ];
    };
  };
}
