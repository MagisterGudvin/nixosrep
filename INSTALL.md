# Установка и сопровождение конфигурации

Репозиторий: `github.com/magistergudvin/nixosrep`
Хост: `Forza` (имя хоста = имя flake-output-а `nixosConfigurations.Forza`)
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

### 1.3. Собери hardware-configuration.nix для этой машины

`nixos-generate-config` смотрит на железо примонтированной системы и пишет `hardware-configuration.nix` с автодетектом `boot.initrd.availableKernelModules`, `boot.kernelModules`, `hostPlatform` и т.п. — то, что специфично именно для этого ноутбука.

В корне репо лежит `insert-etc-nixos.sh`, который:
1. вызывает `nixos-generate-config --no-filesystems --root /mnt` во временный каталог,
2. копирует результат в `modules/hosts/Forza/hardware-configuration.nix`,
3. переписывает `modules/hosts/Forza/hardware.nix` в тонкую обёртку (`flake.nixosModules.ForzaHardware = import ./hardware-configuration.nix;`).

Запуск:

```bash
cd /mnt/etc/nixos
sudo ./insert-etc-nixos.sh /mnt
```

Проверь дифф (если репо стартовый — увидишь, что заменилось ручное содержимое `hardware.nix` и добавился `hardware-configuration.nix`):

```bash
git diff modules/hosts/Forza/
```

> **Почему `--no-filesystems`:** иначе генератор припишет автодетектные `fileSystems."/"`, `fileSystems."/boot"` и `swapDevices`, которые конфликтнут с уже описанными в `modules/system/filesystems.nix`. Скрипт всегда зовёт генератор с этим флагом.

> Конфликта с другими модулями нет: автогенерированный файл выставляет `nixpkgs.hostPlatform`, `boot.kernelModules += [kvm-amd]`, `hardware.cpu.amd.updateMicrocode` через `lib.mkDefault`, так что явные значения в `modules/system/{cpu,nix}.nix` побеждают. Списки `boot.initrd.availableKernelModules` мёржатся, ничего не теряется.

Если на этой машине автодетект уже совпадает с тем, что лежит в репо — коммитить нечего; если есть отличия, потом закоммитишь:

```bash
git add modules/hosts/Forza/hardware-configuration.nix modules/hosts/Forza/hardware.nix
git commit -m "Sync hardware-configuration for Forza"
```

### 1.4. Накати систему

```bash
sudo nixos-install --flake /mnt/etc/nixos#Forza --no-root-password
```

`#Forza` — это имя из `flake.nixosConfigurations.Forza` (см. `modules/hosts/Forza/default.nix`). Если переименуешь хост — флаг меняется соответственно.

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
sudo nixos-rebuild switch --flake .#Forza
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
sudo nixos-rebuild switch --flake .#Forza
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
sudo nixos-rebuild switch --flake .#Forza
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
sudo nixos-rebuild switch --flake .#Forza
```

> Если правишь конфиг с другой машины и хочешь подтянуть на Forza:
> ```bash
> git pull
> sudo nixos-rebuild switch --flake .#Forza
> ```

---

## 5. Полезное в быту

### Поиск пакета / опции
- Пакеты: https://search.nixos.org/packages?channel=unstable
- Опции NixOS: https://search.nixos.org/options?channel=unstable
- Опции Home-Manager: https://home-manager-options.extranix.com/

### Сборка только проверить (без активации)
```bash
nixos-rebuild build --flake .#Forza
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
sudo nixos-rebuild switch --flake .#Forza --show-trace
```

### Hibernate
Размер swap-партиции (36 GiB) рассчитан под RAM 32 GiB + 4 GiB margin. После загрузки:
```bash
sudo systemctl hibernate
```
