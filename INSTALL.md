# Установка и сопровождение конфигурации

Репозиторий: `github.com/magistergudvin/nixosrep`
Хост: `forza` (имя хоста = имя flake-output-а `nixosConfigurations.forza`)
Пользователь: `gooblin`

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
git clone https://github.com/magistergudvin/nixosrep /mnt/etc/nixos
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
# Обновить всё (nixpkgs, home-manager, noctalia и т.д.)
nix flake update

# Обновить один input
nix flake update nixpkgs

# После — применить
sudo nixos-rebuild switch --flake .#forza
```

### 2.3. Откатиться, если что-то сломалось

В меню systemd-boot при загрузке есть прошлые поколения. Выбирай предыдущее — загрузишься в рабочую систему. Из работающей системы:

```bash
# Список поколений
sudo nix-env --list-generations -p /nix/var/nix/profiles/system

# Откат на предыдущее
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
- Если есть, но имя странное (`vscode-fhs`, `kdePackages.breeze-icons`) — используй ровно то имя.
- Если пакета нет — нужно либо подключить чужой flake как input в `flake.nix`, либо написать свой `package.nix` через `pkgs.callPackage`. Это уже отдельная история, в этой инструкции не покрывается.

---

## 4. Как пушить изменения в репозиторий

Сессионный SSH/HTTPS-доступ к `github.com/magistergudvin/nixosrep` должен быть настроен (`gh auth login` или SSH-ключ).

### 4.1. Цикл правки

```bash
cd ~/nixosrep              # путь до клона репо у тебя
git status                 # посмотри, что изменилось
git diff                   # детально
```

### 4.2. Закоммитить

```bash
git add modules/home/packages.nix          # конкретные файлы
# или
git add -A                                 # всё сразу

git commit -m "Add blockbench to home packages"
```

Стиль сообщений в репо: одна строка-заголовок в повелительном наклонении, опционально пара строк деталей через пустую строку.

### 4.3. Запушить

```bash
git push
```

Если ветка ещё не отслеживает upstream:
```bash
git push -u origin main
```

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
```bash
sudo nix-collect-garbage -d            # удалить ВСЕ старые поколения
sudo nix-collect-garbage --delete-older-than 14d
```

### Что сломалось — где смотреть
```bash
journalctl -xeu nixos-rebuild
journalctl -b -p err                   # ошибки текущей загрузки
sudo nixos-rebuild switch --flake .#forza --show-trace
```

### Hibernate
Размер swap-партиции (36 GiB) рассчитан под RAM 32 GiB + 4 GiB margin. После загрузки:
```bash
sudo systemctl hibernate
```

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

В меню systemd-boot при старте есть **прошлые поколения** — выбираешь любое более старое, загружаешься в рабочую систему. Из неё:

```bash
sudo nixos-rebuild switch --rollback
# либо
sudo nix-env --list-generations -p /nix/var/nix/profiles/system   # посмотреть номера
sudo nix-env --switch-generation N -p /nix/var/nix/profiles/system && sudo nixos-rebuild switch
```

### Если просто хочется чистоты на диске

```bash
# Удалить системные поколения старше 7 дней (текущее и одно-два прошлых остаются)
sudo nix-collect-garbage --delete-older-than 7d

# Или агрессивно — всё кроме текущего поколения
sudo nix-collect-garbage -d
```

Это очистит `/nix/store` от мусора и подрежет меню systemd-boot. Сама система не страдает.

### Когда полная переустановка с нуля действительно нужна

Только если:

- сломан bootloader (`/boot` испорчен, EFI-запись затёрта);
- случайно стёрт `/nix/store` или раздел с ним;
- меняешь схему разделов или файловую систему корня.

Во всех остальных случаях `git pull && sudo nixos-rebuild switch --flake .#forza` (или откат на предыдущее поколение) дешевле и быстрее.

### Если всё-таки нужна полная переустановка

Идёшь по этому же INSTALL.md с шага **1** (live ISO → разметка → клонирование → `nixos-install`). Репозиторий `magistergudvin/nixosrep` уже содержит всю историю правок, так что новой системе достанется именно тот стейт, что есть в `main` на момент клонирования.
