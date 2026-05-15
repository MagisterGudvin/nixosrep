{ ... }: {
  flake.nixosModules.wireguard = { pkgs, ... }: {
    # CLI: wg, wg-quick. Ядерный модуль wireguard загружается
    # автоматически по требованию.
    environment.systemPackages = [ pkgs.wireguard-tools ];

    # NetworkManager поддерживает WireGuard нативно с v1.16, дополнительных
    # плагинов не нужно. Импорт чужого .conf:
    #
    #   sudo nmcli connection import type wireguard file /path/to/peer.conf
    #
    # GUI: правый клик по сетевому индикатору → Add → WireGuard, либо
    # nmtui (TUI-конфигуратор).
  };
}
