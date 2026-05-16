{ ... }: {
  flake.nixosModules.wireguard = { pkgs, ... }: {
    # CLI: wg, wg-quick. Ядерный модуль wireguard загружается
    # автоматически по требованию.
    # network-manager-applet (nm-applet) — даёт системный tray-значок
    # сети с подменю VPN. В noctalia ловится виджетом Tray.
    environment.systemPackages = with pkgs; [
      wireguard-tools
      networkmanagerapplet
    ];

    # NetworkManager поддерживает WireGuard нативно с v1.16, дополнительных
    # плагинов не нужно. Импорт чужого .conf:
    #
    #   sudo nmcli connection import type wireguard file /path/to/peer.conf
    #   sudo nmcli connection modify <name> connection.autoconnect yes
    #
    # GUI: ЛКМ/ПКМ по значку nm-applet в Tray noctalia → VPN Connections →
    # тоггл вкл/выкл. Либо `nmtui` (TUI).
  };
}
