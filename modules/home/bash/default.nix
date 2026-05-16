{ ... }: {
  flake.homeModules.bash = { pkgs, ... }: {
    programs.starship = {
      enable = true;
      settings = {
        # Показываем user@host всегда (по умолчанию starship прячет
        # их в локальной сессии). Под ч/б обои — вся подсказка идёт
        # оттенками серого (ANSI 240..255), без цветовых акцентов.
        format = "$username[@](bold 250)$hostname $directory$git_branch$git_status$character";
        username = {
          show_always = true;
          format = "[$user]($style)";
          style_user = "bold 252";
          style_root = "bold 255";       # root немного ярче
        };
        hostname = {
          ssh_only = false;
          format = "[$hostname]($style)";
          style = "bold 248";
        };
        directory = {
          style = "bold 254";
        };
        git_branch = {
          style = "246";
          format = "[ $symbol$branch]($style)";
        };
        git_status = {
          style = "240";
        };
        character = {
          success_symbol = "[❯](250)";
          error_symbol = "[❯](240)";
        };
      };
    };

    programs.bash = {
      enable = true;

      shellAliases = {
        ff = "clear && fastfetch";
        fm = "yazi";
        cdlw = "cd /run/media/gooblin/lw";
      };

      bashrcExtra = ''
        if [[ $- == *i* ]]; then
          fastfetch
        fi
      '';
    };
  };
}
