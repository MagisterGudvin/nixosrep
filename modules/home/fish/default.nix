{ ... }: {
  flake.homeModules.fish = { pkgs, ... }: {
    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        set fish_greeting ""

        # Монохромная подсветка под ч/б обои. Используем hex-коды
        # вместо ANSI-номеров — fish 4.x иногда некорректно их
        # отображает (выходит цвет вместо нейтрального серого).
        # Заодно чистим universal-скоуп, если что-то осталось от
        # предыдущих экспериментов.
        for c in normal command param quote redirection comment error \
                 autosuggestion operator escape cwd user host \
                 keyword option valid_path end
            set -e -U fish_color_$c 2>/dev/null
        end
        for c in progress completion description prefix
            set -e -U fish_pager_color_$c 2>/dev/null
        end

        set -g fish_color_normal       E0E0E0
        set -g fish_color_command      F5F5F5 --bold
        set -g fish_color_keyword      F0F0F0 --bold
        set -g fish_color_param        D0D0D0
        set -g fish_color_option       C8C8C8
        set -g fish_color_quote        B0B0B0
        set -g fish_color_redirection  A0A0A0
        set -g fish_color_comment      707070
        set -g fish_color_error        FFFFFF --bold
        set -g fish_color_autosuggestion 808080
        set -g fish_color_operator     E0E0E0
        set -g fish_color_escape       B8B8B8
        set -g fish_color_valid_path   D0D0D0
        set -g fish_color_end          C0C0C0
        set -g fish_color_cwd          F0F0F0
        set -g fish_color_user         E0E0E0
        set -g fish_color_host         B8B8B8
        set -g fish_color_search_match --background=383838
        set -g fish_color_selection    --background=383838

        set -g fish_pager_color_progress   707070
        set -g fish_pager_color_completion D8D8D8
        set -g fish_pager_color_description A0A0A0
        set -g fish_pager_color_prefix     F0F0F0 --bold

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

        # Чистый рестарт noctalia: убиваем quickshell, новую копию
        # просим запустить niri (не наш fish), чтобы окно kitty
        # не держало процесс и не цеплялся к нему по stdout.
        noctalia-restart = "pkill -9 quickshell; and sleep 1; and niri msg action spawn -- noctalia-shell";
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
