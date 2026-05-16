{ ... }: {
  flake.homeModules.kitty = { pkgs, ... }: {
    programs.kitty = {
      enable = true;

      # Тему не задаём через themeFile — определяем монохромную палитру
      # прямо в settings ниже. Это согласует kitty с ч/б обоями.

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

        # Прозрачный чёрный фон. Сильнее прозрачность чем было — чтобы
        # обои за окном просвечивали и давали ч/б тон.
        background = "#000000";
        background_opacity = "0.70";
        dynamic_background_opacity = "yes";
        # background_blur — kitty просит у компитора blur-протокол.
        # niri поддерживает (через ext-blur/layer-shell-effects), так
        # что если работает — фон станет матовым; если нет — просто
        # будет прозрачный без блюра, без ошибок.
        background_blur = "32";

        # Монохромная палитра. Фон — чистый чёрный, текст — тёплый
        # светло-серый. ANSI-цвета все приведены к серым ступенькам
        # (без красного/зелёного/синего), чтобы любой вывод оставался
        # в ч/б эстетике обоев.
        foreground = "#d0d0d0";
        cursor = "#e6e6e6";
        cursor_text_color = "#000000";

        selection_background = "#404040";
        selection_foreground = "#ffffff";

        # Normal colors
        color0 = "#1a1a1a";   # black
        color1 = "#707070";   # red    → mid gray
        color2 = "#888888";   # green  → mid gray
        color3 = "#a0a0a0";   # yellow → light gray
        color4 = "#707070";   # blue
        color5 = "#888888";   # magenta
        color6 = "#a0a0a0";   # cyan
        color7 = "#c0c0c0";   # white

        # Bright colors (используются для bold/highlight)
        color8 = "#404040";
        color9 = "#909090";
        color10 = "#a8a8a8";
        color11 = "#c0c0c0";
        color12 = "#909090";
        color13 = "#a8a8a8";
        color14 = "#c0c0c0";
        color15 = "#ffffff";

        # URL underline тоже серый, не синий.
        url_color = "#b0b0b0";

        # Активные/неактивные tab-таблы под общую гамму.
        active_tab_background = "#3a3a3a";
        active_tab_foreground = "#f0f0f0";
        inactive_tab_background = "#1a1a1a";
        inactive_tab_foreground = "#909090";

        # Курсор blinking beam — приятнее блока на тёмной теме.
        cursor_shape = "beam";
        cursor_blink_interval = "0.5";

        # Дёргать терминалом по любому пиксельному edge.
        window_padding_width = "8";

        # Без писков.
        enable_audio_bell = "no";

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
