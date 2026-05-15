{ ... }: {
  flake.homeModules.kitty = { pkgs, ... }: {
    programs.kitty = {
      enable = true;

      # Tokyo Night Moon — та же палитра, что у rofi
      # (см. modules/home/rofi/tokyonight-moon.rasi).
      themeFile = "Tokyo_Night_Moon";

      font = {
        name = "JetBrainsMono Nerd Font";
        package = pkgs.nerd-fonts.jetbrains-mono;
        size = 11;
      };

      shellIntegration.enableFishIntegration = true;

      settings = {
        # niri выставляет prefer-no-csd, плюс сам кладёт обводку и
        # закругления (см. window-rules для app-id="kitty" в niri.nix).
        # Поэтому отключаем kitty-овский title bar — niri отрисует фрейм
        # сам.
        hide_window_decorations = "yes";

        # Прозрачность 0.92 — синхронно со значением opacity в niri
        # window-rule, чтобы по любому пути (niri-shader или собственный
        # композит kitty) получался один и тот же тон.
        background_opacity = "0.92";
        dynamic_background_opacity = "yes";

        # Курсор blinking beam — приятнее блока на тёмной теме.
        cursor_shape = "beam";
        cursor_blink_interval = "0.5";

        # Дёргать терминалом по любому пиксельному edge.
        window_padding_width = "8";

        # Без писков.
        enable_audio_bell = "no";

        # Передаём X-курсор тему через env, kitty его подхватит из niri.
        # (XCURSOR_THEME=volantes_cursors, XCURSOR_SIZE=32 заданы в niri
        # environment.)

        # Закрывать терминал, когда дочерний шелл выходит.
        close_on_child_death = "yes";

        # Mouse-scrollback: 10k строк хватает на длинные nixos-rebuild
        # выводы.
        scrollback_lines = "10000";

        # Конфиденциальный clipboard: блокировка чтения, разрешена только
        # запись по Ctrl+Shift+C (по умолчанию). Безопаснее, чем
        # default "read".
        clipboard_control = "write-clipboard write-primary no-append";
      };
    };
  };
}
