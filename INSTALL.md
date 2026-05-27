# Установка и сопровождение конфигурации

Репозиторий: `github.com/MagisterGudvin/nixosrep`
Хост: `forza` (имя хоста = имя flake-output-а `nixosConfigurations.forza`)
Пользователь: `gooblin`

Что внутри:
- **Ядро:** `linuxPackages_latest` (последнее стабильное; нужно для Radeon 780M / amd_pstate)
- **nixpkgs:** канал `nixos-unstable`
- **niri:** через `niri-flake` (stable, v25.08+; обновляется `nix flake update niri`)
- **noctalia:** мастер-ветка, обновляется `nix flake update noctalia`
- **home-manager:** мастер, follows nixpkgs
- **yandex-browser:** сторонний флейк `miuirussia/yandex-browser.nix` — официальный .deb распакован и пропатчен `autoPatchelfHook`. Кэш `yandex-browser-nix.cachix.org` подключён в `modules/system/nix.nix`.

---

## 1. Первая установка (с live ISO)

Загрузись с **NixOS minimal ISO** (https://nixos.org/download). Разметка дисков и форматирование уже сделаны до этого шага — корень btrfs смонтирован в `/mnt`, ESP в `/mnt/boot`, сабволы `@`, `@home`, `@nix` подняты, swap создан с меткой `swap`.

### 1.1. Включи flakes-эксперименты для live-сессии

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
```

### 1.2. Клонируй репозиторий в `/mnt`

```bash
nix-shell -p git
git clone https://github.com/MagisterGudvin/nixosrep /mnt/etc/nixos
cd /mnt/etc/nixos
```

> Можно класть куда угодно (например `/mnt/home/gooblin/nixosrep`) — путь к flake-у явный, `/etc/nixos` это просто привычка.

### 1.3. Сверь hardware-конфиг с автодетектом

`nixos-generate-config` смотрит на железо примонтированной системы и пишет `hardware-configuration.nix` с найденными `boot.initrd.availableKernelModules`, `boot.kernelModules`, `hostPlatform` и т.п.

В репе всё это уже задано вручную (`modules/hosts/forza/hardware.nix`, `modules/system/cpu.nix`, `modules/system/nix.nix`). Но генератор может найти модули, которых нет в твоём списке (например, для нестандартного NVMe-контроллера или ридера SD). Прогоняем с флагом `--no-filesystems`, чтобы не плодить дубли с `filesystems.nix`:

```bash
sudo nixos-generate-config --no-filesystems --root /mnt --dir /tmp/genconf
cat /tmp/genconf/hardware-configuration.nix
```

Сравни выведенный `boot.initrd.availableKernelModules` со списком в `modules/hosts/forza/hardware.nix`. Если в сгенерированном есть что-то отсутствующее (типичные кандидаты: `ahci`, `nvme`, `xhci_pci`, `usbhid`, `usb_storage`, `sd_mod`, `sdhci_pci`, `rtsx_pci_sdmmc` для ридеров карт) — допиши недостающее в `hardware.nix` и закоммить позже.

> Зачем `--no-filesystems`: иначе генератор положит автодетектные `fileSystems."/"`, `fileSystems."/boot"`, `swapDevices` — и они конфликтнут с уже описанными в `modules/system/filesystems.nix`. С флагом он эти секции пропускает.

### 1.4. Накати систему

```bash
sudo nixos-install --flake /mnt/etc/nixos#forza --no-root-password
```

`#forza` — это имя из `flake.nixosConfigurations.forza` (см. `modules/hosts/forza/default.nix`). Если переименуешь хост — флаг меняется соответственно.

### 1.5. Поставь пароль пользователю `gooblin`

В конце установщик предложит установить root-пароль (мы передали `--no-root-password`, чтобы пропустить — wheel-юзер с `sudo` достаточно). Для пользователя:

```bash
sudo nixos-enter --root /mnt -c 'passwd gooblin'
```

### 1.6. Перезагрузка

```bash
sudo reboot
```

После ребута на VT1 поднимется **tuigreet** — выбери `niri` в сессиях, введи пароль `gooblin`.

---

## 2. Повседневная работа

Все команды ниже выполняются в склонированном репозитории (`cd ~/nixosrep` или где он у тебя лежит).

### 2.1. Применить изменения

```bash
sudo nixos-rebuild switch --flake .#forza
```

Варианты вместо `switch`:
- `test` — применить **без записи в bootloader** (откатится после ребута). Полезно проверить рискованное изменение.
- `boot` — применить только при следующей загрузке.
- `build` — собрать, не активировать.

### 2.2. Обновить версии (flake.lock)

```bash
# Обновить всё (nixpkgs, home-manager, noctalia, niri, yandex-browser)
nix flake update

# Обновить один input
nix flake update niri

# После — применить
sudo nixos-rebuild switch --flake .#forza
```

`flake.lock` — это файл с точными SHA коммитов каждого input-а. Его **обязательно нужно коммитить в git**, иначе система перестанет быть воспроизводимой.

### 2.2.1. Yandex Browser — отдельный цикл обновления

Yandex чистит старые билды из своего .deb-репозитория, поэтому если `flake.lock` для `yandex-browser` отстал больше чем на месяц, при rebuild `fetchurl` упадёт на HTTP 404.

Симптом — раз в неделю в notify-send прилетает «Yandex Browser: обновление». Это user-systemd-таймер (`yandex-browser-update-check`) сравнивает rev в `flake.lock` с master upstream'а и зовёт тебя обновить:

```bash
cd ~/nixosrep
nix flake update yandex-browser
sudo nixos-rebuild switch --flake .#forza
```

Принудительный запуск проверки (например, после восстановления из бэкапа): `systemctl --user start yandex-browser-update-check`. Журнал: `journalctl --user -u yandex-browser-update-check`.

### 2.3. Откатиться, если что-то сломалось

В меню systemd-boot при загрузке есть последние 5 поколений (лимит задан в `modules/system/boot.nix`). Выбирай предыдущее — загрузишься в рабочую систему. Из работающей системы:

```bash
sudo nix-env --list-generations -p /nix/var/nix/profiles/system
sudo nixos-rebuild switch --rollback
```

---

## 3. Как добавлять пакеты

### 3.1. Пользовательские GUI/CLI-приложения (Home-Manager)

Файл: `modules/home/packages.nix`

```nix
home.packages = with pkgs; [
  ...
  blockbench   # ← добавь сюда
];
```

Найти пакет: https://search.nixos.org/packages

После правки:
```bash
sudo nixos-rebuild switch --flake .#forza
```

### 3.2. Системные сервисы и пакеты (NixOS)

Если пакету нужен системный сервис (демоны, FHS-обёртки, сетевые порты) — это NixOS-модуль, а не HM:

- **Steam** → `modules/system/steam.nix` (`programs.steam.enable`)
- **Bluetooth** → `modules/system/bluetooth.nix`
- **Принтеры** → `services.printing.enable`

Шаблон нового системного модуля (например, `modules/system/docker.nix`):

```nix
{ ... }: {
  flake.nixosModules.docker = { ... }: {
    virtualisation.docker.enable = true;
    users.users.gooblin.extraGroups = [ "docker" ];
  };
}
```

И зарегистрируй в `modules/system/default.nix` — добавь `self.nixosModules.docker` в список `imports`.

### 3.3. Новый Home-Manager модуль

Шаблон (например, `modules/home/foo.nix`):

```nix
{ ... }: {
  flake.homeModules.foo = { pkgs, ... }: {
    programs.foo.enable = true;
  };
}
```

Зарегистрируй в `modules/home/default.nix` — добавь `self.homeModules.foo` в `imports` блока `users.gooblin`.

> Почему обёртка `flake.homeModules.X = …`? Репо использует `flake-parts` + `import-tree` — каждый `.nix` под `modules/` грузится как flake-parts-модуль. Голый HM-модуль на верхнем уровне ломает eval.

### 3.4. Если пакет в nixpkgs называется иначе или его нет

- Сначала проверь: https://search.nixos.org/packages
- Если есть, но имя странное (`vscode-fhs`, `kdePackages.breeze-icons`, `nerd-fonts.jetbrains-mono`) — используй ровно то имя.
- Если пакета нет — нужно либо подключить чужой flake как input в `flake.nix`, либо написать свой `package.nix` через `pkgs.callPackage`. Это уже отдельная история, в этой инструкции не покрывается.

### 3.5. Настройка noctalia

Весь конфиг noctalia декларативный — лежит в `modules/home/noctalia/default.nix`. При rebuild HM записывает оттуда `~/.config/noctalia/settings.json` (как симлинк в /nix/store, **read-only**). Поэтому правки через noctalia UI не переживут rebuild — менять надо в nix-файле:

1. Открой `modules/home/noctalia/default.nix`.
2. Найди нужное поле — структура соответствует разделам noctalia (general, bar, colorSchemes, wallpaper и т.д.).
3. Меняй значение (например `predefinedScheme = "Catppuccin Mocha"` для смены цветовой схемы).
4. Коммить и пушь:
   ```bash
   git add modules/home/noctalia/default.nix
   git commit -m "noctalia: switch theme"
   git push
   sudo nixos-rebuild switch --flake .#forza
   ```

Доступные predefinedScheme — открой noctalia → ControlCenter в баре → Settings → Color schemes, перечислены там.

---

## 4. Как пушить изменения в репозиторий (SSH)

Аутентификация — через SSH-ключ. Один раз настроил → пушишь без паролей и токенов.

### 4.1. Первичная настройка SSH (один раз на машину)

```bash
# 1) Генерируем ключ
ssh-keygen -t ed25519 -C "gooblin@forza" -f ~/.ssh/id_ed25519 -N ""

# 2) Печатаем публичный ключ
command cat ~/.ssh/id_ed25519.pub
```

Скопируй полностью строку `ssh-ed25519 AAAA... gooblin@forza` и добавь её в **https://github.com/settings/keys** → New SSH key → вставить → Add.

```bash
# 3) Проверяем
ssh -T git@github.com    # должно ответить "Hi MagisterGudvin!"

# 4) Переключаем remote репозитория на ssh (если был https)
cd ~/nixosrep
git remote set-url origin git@github.com:MagisterGudvin/nixosrep.git
git remote -v
```

### 4.2. Цикл правки

```bash
cd ~/nixosrep                  # путь до клона репо
git status                     # посмотри, что изменилось
git diff                       # детально

git add modules/home/packages.nix     # конкретные файлы
# или
git add -A                            # всё сразу

git commit -m "Add blockbench"

git push                              # уйдёт в origin/main по SSH
```

Стиль сообщений: одна короткая строка-заголовок в повелительном наклонении, опционально пара строк деталей через пустую строку.

### 4.3. Подводные камни git

- **`sudo git pull` не работает** — `sudo` подменяет окружение, ssh-ключ берётся root-овский, которого в GitHub нет. Всегда `git pull` без sudo.
- **«dubious ownership in repository»** — файлы репо принадлежат не тебе (часто после клонирования из live ISO они оказываются root-овскими). Лечится:
  ```bash
  sudo chown -R gooblin:users ~/nixosrep
  ```
- **Забыл `git add`** — `git push` скажет `Everything up-to-date`. Проверь `git status` — там покажет неотслеживаемые файлы или несоставленные изменения.

### 4.4. Применить запушенное на самой машине

Push сам по себе ничего не меняет в работающей системе — нужно ещё раз пересобрать:

```bash
sudo nixos-rebuild switch --flake .#forza
```

> Если правишь конфиг с другой машины и хочешь подтянуть на forza:
> ```bash
> git pull
> sudo nixos-rebuild switch --flake .#forza
> ```

---

## 5. Полезное в быту

### Поиск пакета / опции
- Пакеты: https://search.nixos.org/packages?channel=unstable
- Опции NixOS: https://search.nixos.org/options?channel=unstable
- Опции Home-Manager: https://home-manager-options.extranix.com/

### Сборка только проверить (без активации)
```bash
nixos-rebuild build --flake .#forza
```

### Очистка старых поколений

GC запускается автоматически раз в неделю и удаляет всё старше 7 дней (см. `modules/system/nix.nix` → `nix.gc`). Меню systemd-boot при этом держит максимум 5 пунктов (`boot.loader.systemd-boot.configurationLimit = 5`).

Если хочется почистить вручную:

```bash
# Удалить системные поколения старше N дней
sudo nix-collect-garbage --delete-older-than 14d

# Удалить ВСЕ старые поколения, кроме текущего
sudo nix-collect-garbage -d

# После — подровнять меню bootloader (иначе старые пункты могут остаться)
sudo /run/current-system/bin/switch-to-configuration boot
```

Проверить освободившееся место:
```bash
du -sh /nix/store
sudo nix-env --list-generations -p /nix/var/nix/profiles/system
ls /boot/loader/entries/
```

### Полная очистка системы

Несколько слоёв «мусора», которые накапливаются вне Nix-store и не подметаются автоGC. Команды можно запускать выборочно — каждый блок независим.

**1. Nix-кэши и старые поколения**

```bash
sudo nix-collect-garbage -d        # системные поколения, кроме текущего
nix-collect-garbage -d              # user-поколения (home-manager)
sudo /run/current-system/bin/switch-to-configuration boot
rm -rf ~/.cache/nix ~/.cache/nix-flakes 2>/dev/null
sudo nix-store --optimise           # дедуп через hard-link'и
```

**2. История команд (фоновое хранение всего, что ты набирал)**

```bash
# atuin (наш дефолтный backend истории — SQLite, перехватывает Up-arrow и Ctrl+R)
rm ~/.local/share/atuin/history.db*

# fish_history (родная история fish)
rm ~/.local/share/fish/fish_history

# bash_history (если иногда запускал bash)
rm ~/.bash_history 2>/dev/null

# less, python-REPL, neovim ShaDa — мелкая мелочь
rm -f ~/.lesshst ~/.python_history
rm -rf ~/.local/share/nvim/shada 2>/dev/null
```

После — закрой все kitty (`pkill kitty`), при следующем открытии стрелка-вверх будет пустой.

**3. SSH-следы (`~/.ssh/known_hosts`)**

```bash
# Что в файле сейчас
awk '{print $1}' ~/.ssh/known_hosts | sort -u

# Удалить конкретный сервер (оставит github и прочее нужное)
ssh-keygen -R 1.2.3.4
ssh-keygen -R example.com

# Снести весь файл (при следующем ssh нужно будет подтверждать fingerprint'ы заново)
rm ~/.ssh/known_hosts ~/.ssh/known_hosts.old 2>/dev/null
```

**4. journald-логи**

```bash
sudo journalctl --disk-usage
sudo journalctl --vacuum-time=7d      # оставить только последние 7 дней
sudo journalctl --vacuum-size=500M    # или ограничить общий размер
```

**5. XDG-кэш приложений (`~/.cache/`)**

```bash
du -sh ~/.cache/* 2>/dev/null | sort -h | tail -10   # топ-10 пожирателей
rm -rf ~/.cache/thumbnails             # миниатюры
rm -rf ~/.cache/mesa_shader_cache      # GL shaders
rm -rf ~/.cache/radv                   # Vulkan RADV cache
rm -rf ~/.cache/yandex-browser ~/.cache/BraveSoftware  # кэш браузеров (профиль не трогаем)
```

**6. Steam — shader cache, не сами игры**

```bash
du -sh ~/.local/share/Steam/steamapps/shadercache
rm -rf ~/.local/share/Steam/steamapps/shadercache
# Игра при следующем запуске пересоберёт шейдеры (первая минута будет лагать).
```

Если совсем сломан Proton-префикс для какой-то игры — снести его персонально (не общий!):
```bash
ls ~/.local/share/Steam/steamapps/compatdata/      # appid'ы
rm -rf ~/.local/share/Steam/steamapps/compatdata/<appid>
```

**7. Home-Manager backup-файлы**

При каждой activation home-manager делает `.bak` для файлов, которые пишет поверх юзерских. С годами их накапливается:

```bash
find ~/.config ~/.local/share -name "*.bak" 2>/dev/null | head
find ~/.config ~/.local/share -name "*.bak" -delete
```

**8. `/tmp` и `/var/tmp`**

```bash
sudo du -sh /tmp /var/tmp
# /tmp обычно tmpfs (RAM) — очищается на reboot, не трогаем
# /var/tmp — на диске:
sudo systemd-tmpfiles --clean
```

**Одной командой — «всё что не страшно сразу»:**

```bash
sudo nix-collect-garbage -d && \
nix-collect-garbage -d && \
rm -rf ~/.cache/nix ~/.cache/thumbnails ~/.cache/mesa_shader_cache ~/.cache/radv && \
rm -f ~/.local/share/atuin/history.db* ~/.local/share/fish/fish_history ~/.bash_history && \
find ~/.config ~/.local/share -name "*.bak" -delete && \
sudo journalctl --vacuum-time=7d && \
sudo /run/current-system/bin/switch-to-configuration boot && \
sudo nix-store --optimise && \
df -h | grep -vE "tmpfs|devtmpfs"
```

**Что НЕ трогать руками:**
- `/nix/store/*` — только через `nix-collect-garbage`. Любой `rm` там → сломанная система.
- `~/.local/share/Steam/steamapps/common/*` — это сами игры (десятки гигабайт каждая). Удалять через Steam UI.
- `~/.config/*` без понимания что чистишь — там твои настройки, профили, ключи. Браузерные `~/.cache/*` чистить можно, `~/.config/yandex-browser` (профиль) — нет.

### Что сломалось — где смотреть
```bash
journalctl -xeu nixos-rebuild
journalctl -b -p err                         # ошибки текущей загрузки
journalctl -b -1 -p err                      # ошибки предыдущей загрузки
sudo nixos-rebuild switch --flake .#forza --show-trace
journalctl --user -b _COMM=niri --no-pager   # лог niri-сессии
systemctl --failed --no-pager                # упавшие system-юниты
systemctl --user --failed --no-pager         # упавшие user-юниты
systemctl is-system-running                  # 'running' = ok, 'degraded' = есть failed
systemd-analyze blame | head                 # топ-замедлителей boot'а
systemd-analyze critical-chain               # критическая цепочка boot'а
```

Известный фон, лечению не подлежит и не индикатор реальных проблем:
- `ACPI BIOS Error: AE_ALREADY_EXISTS` ×8 — баг в прошивке MECHREVO, ОС не лечит
- `dbus-broker Ignoring duplicate name ...` (~50 строк) — нормальная архитектура NixOS, service-файлы попадают в `system-path` и в `dbus-1/` одного пакета
- `bluetoothd: Failed to set default system config for hci0` — прошивка BT-чипа не принимает все mgmt-параметры ядра
- `bluetoothd: Error reading PNP_ID: Invalid pdu length` — конкретное paired BT-устройство шлёт битый DIS-профиль
- `hyprpolkitagent: Failed to register with host portal QDBusError ... Could not register app ID` — косметика, polkit-диалоги работают (`pkexec id` подтверждает)
- `wireplumber: Failed to get percentage from UPower: NameHasNoOwner` — race condition при старте, через секунду UPower поднимается и всё ок
- `niri WARN: EglExtensionNotSupported(["EGL_WL_bind_wayland_display"])` — это опциональное расширение, на Mesa+Radeon отсутствует штатно

### Hibernate
Размер swap-партиции (36 GiB) рассчитан под RAM 32 GiB + 4 GiB margin. После загрузки:
```bash
sudo systemctl hibernate
```

### WireGuard / VPN

NetworkManager умеет WireGuard нативно. Чтобы импортировать чужой конфиг:

```bash
sudo nmcli connection import type wireguard file /путь/к/peer.conf
sudo nmcli connection modify <name> connection.autoconnect yes
```

Управлять — через значок `nm-applet` в Tray noctalia (он автостартует с niri). ЛКМ/ПКМ по значку → **VPN Connections** → имя профиля → тоггл.

### Steam / игры

Современные DX12/Vulkan игры на niri лучше запускать с `PROTON_USE_WAYLAND=1` — это говорит Proton-GE использовать нативный wayland-driver wine'а вместо XWayland. Картинка идёт прямо в `steam_app_*` surface, никаких чёрных окон, тайл нормально фуллскринится.

В Steam → Свойства игры → Параметры запуска:
```
PROTON_USE_WAYLAND=1 %command%
```

Для старых DX9/DX11 — оставлять параметры пустыми, обычный XWayland-режим. `gamescope` в конфиге не установлен и в niri не маппится (`xdg-toplevel` не появляется в композиторе) — не пытаться использовать.

### Съёмные диски

В `modules/system/filesystems.nix` объявлен mount-point `/run/media/gooblin/lw` с опцией `x-systemd.automount`. Диск **не обязан быть подключён** при загрузке — systemd ставит lazy-mount, монтирует на первое обращение, отмонтирует через 60 секунд idle.

Чтобы добавить ещё один съёмный диск, по аналогии:
```nix
fileSystems."/run/media/gooblin/<label>" = {
  device = "/dev/disk/by-label/<label>";
  fsType = "ext4";   # или btrfs, exfat, ntfs3 и т.д.
  options = [
    "defaults"
    "nofail"
    "x-systemd.device-timeout=1"
    "x-systemd.automount"
    "x-systemd.idle-timeout=60"
  ];
};
```

### Архивы / Thunar «Извлечь сюда»

В NixOS thunar-archive-plugin (TAP) и xarchiver лежат в разных store-prefix, и TAP не находит `xarchiver.tap` (apstream рассчитан на /usr/libexec/). В `modules/system/thunar.nix` мы пересобираем TAP через `overrideAttrs.postInstall`, который симлинкует все `.tap` из xarchiver в libexec TAP'а. Никаких ручных действий не требуется — «Извлечь сюда» работает из коробки.

CLI-альтернативы: `nmcli connection up <name>`, `nmcli connection down <name>`, `nmtui`.

---

## 6. «Я что-то сломал, можно начать заново?»

Короткий ответ: **скорее всего — нет, и это не нужно**. NixOS устроен так, что неудавшийся `nixos-rebuild switch` ничего не ломает: новое поколение не активируется, пока не пройдут целиком *eval → build → activate*. Если упало на любом этапе — на машине крутится прошлое успешное поколение, оно цело.

### Если rebuild упал

1. Прочитать сообщение об ошибке (последние ~10 строк перед stack trace), починить файл, попробовать снова:
   ```bash
   sudo nixos-rebuild switch --flake .#forza
   ```
2. Если нужно больше контекста — добавь `--show-trace`.
3. Если правка сложная и хочется сначала только собрать без активации:
   ```bash
   nixos-rebuild build --flake .#forza
   ```

### Если новое поколение активировалось, но при следующей загрузке оно повисло

В меню systemd-boot при старте — последние 5 поколений. Выбираешь любое более старое, загружаешься в рабочую систему. Из неё:

```bash
sudo nixos-rebuild switch --rollback
# либо
sudo nix-env --list-generations -p /nix/var/nix/profiles/system   # посмотреть номера
sudo nix-env --switch-generation N -p /nix/var/nix/profiles/system && sudo nixos-rebuild switch
```

### Когда полная переустановка с нуля действительно нужна

Только если:

- сломан bootloader (`/boot` испорчен, EFI-запись затёрта);
- случайно стёрт `/nix/store` или раздел с ним;
- меняешь схему разделов или файловую систему корня.

Во всех остальных случаях `git pull && sudo nixos-rebuild switch --flake .#forza` (или откат на предыдущее поколение) дешевле и быстрее.

### Если всё-таки нужна полная переустановка

Идёшь по этому же INSTALL.md с шага **1** (live ISO → разметка → клонирование → `nixos-install`). Репозиторий `MagisterGudvin/nixosrep` уже содержит всю историю правок (включая `flake.lock` с пинами версий), так что новой системе достанется именно тот стейт, что есть в `main` на момент клонирования.
