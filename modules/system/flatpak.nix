{ inputs, ... }: {
  flake.nixosModules.flatpak = { ... }: {
    # nix-flatpak расширяет нативный services.flatpak, добавляя
    # декларативные списки packages и remotes. Без него flatpak
    # ставится императивно (`flatpak install ...`), и репо не
    # отражает, что реально установлено.
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

    services.flatpak = {
      enable = true;

      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];

      packages = [
        # Yandex Browser — в nixpkgs нет (Yandex не публикует sources),
        # а на Flathub лежит официальная сборка под appId ru.yandex.Browser.
        "ru.yandex.Browser"
      ];

      # Раз в неделю догонять обновления Flathub. Без этого flatpak
      # обновляется только при ручном `flatpak update`, что ломает
      # идею декларативного контроля.
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };
}
