{ ... }: {
  flake.homeModules.bash = { pkgs, ... }: {
    programs.starship = {
      enable = true;
      settings = {
        # Показываем user@host всегда (по умолчанию starship прячет
        # их в локальной сессии).
        format = "$username[@](bold white)$hostname $directory$git_branch$git_status$character";
        username = {
          show_always = true;
          format = "[$user]($style)";
          style_user = "bold green";
          style_root = "bold red";
        };
        hostname = {
          ssh_only = false;
          format = "[$hostname]($style)";
          style = "bold blue";
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
