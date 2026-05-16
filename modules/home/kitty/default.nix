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

        # Прозрачный чёрный фон. opacity 0.85 — обои читаются под окном,
        # но текст не вязнет в просвечивающей картинке.
        background = "#000000";
        background_opacity = "0.85";
        dynamic_background_opacity = "yes";
        background_blur = "32";

        # Монохромная палитра. Фон — чистый чёрный, текст — почти
        # белый. ANSI-цвета все приведены к серым ступенькам
        # (без красного/зелёного/синего), чтобы любой вывод оставался
        # в ч/б эстетике обоев.
        foreground = "#f0f0f0";
        cursor = "#ffffff";
        cursor_text_color = "#000000";

        selection_background = "#505050";
        selection_foreground = "#ffffff";

        # Normal colors — все cерые, никаких цветовых акцентов
        color0 = "#1a1a1a";   # black
        color1 = "#9a9a9a";   # red    → mid-bright gray
        color2 = "#b0b0b0";   # green  → light gray (был зелёным fish-команд)
        color3 = "#c8c8c8";   # yellow → bright gray
        color4 = "#9a9a9a";   # blue
        color5 = "#b0b0b0";   # magenta
        color6 = "#c8c8c8";   # cyan
        color7 = "#e0e0e0";   # white

        # Bright colors (bold/highlight) — ярче и без оттенков
        color8 = "#505050";
        color9 = "#b8b8b8";
        color10 = "#cccccc";
        color11 = "#e0e0e0";
        color12 = "#b8b8b8";
        color13 = "#cccccc";
        color14 = "#e0e0e0";
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
