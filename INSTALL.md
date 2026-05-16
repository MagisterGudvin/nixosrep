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
# Обновить всё (nixpkgs, home-manager, noctalia, niri)
nix flake update

# Обновить один input
nix flake update niri

# После — применить
sudo nixos-rebuild switch --flake .#forza
```

`flake.lock` — это файл с точными SHA коммитов каждого input-а. Его **обязательно нужно коммитить в git**, иначе система перестанет быть воспроизводимой.

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

### Что сломалось — где смотреть
```bash
journalctl -xeu nixos-rebuild
journalctl -b -p err                         # ошибки текущей загрузки
sudo nixos-rebuild switch --flake .#forza --show-trace
journalctl --user -b _COMM=niri --no-pager   # лог niri-сессии
```

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
