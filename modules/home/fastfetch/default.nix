{ ... }: {
  flake.homeModules.fastfetch = { ... }: {
    home.file.".config/fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "type": "builtin",
        "source": "nixos_small",
        "color": {
          "1": "38;2;208;208;208",
          "2": "38;2;160;160;160"
        },
        "padding": {
          "top": 2,
          "left": 1,
          "right": 3
        }
      },
      "display": {
        "separator": "  ",
        "key": {
          "width": 14,
          "type": "icon"
        },
        "color": "38;2;208;208;208"
      },
      "modules": [
        {
          "type": "custom",
          "format": "\u001b[38;2;240;240;240m󱄅  gooblin\u001b[38;2;144;144;144m@\u001b[38;2;192;192;192mforza\u001b[0m"
        },
        {
          "type": "custom",
          "format": "\u001b[38;2;64;64;64m────────────────────────────────────────\u001b[0m"
        },
        {
          "type": "os",
          "key": "\u001b[38;2;192;192;192m󱄅  OS\u001b[0m",
          "format": "{2} {4}"
        },
        {
          "type": "kernel",
          "key": "\u001b[38;2;192;192;192m  Kernel\u001b[0m",
          "format": "{1}"
        },
        {
          "type": "uptime",
          "key": "\u001b[38;2;192;192;192m󰔟  Uptime\u001b[0m"
        },
        {
          "type": "packages",
          "key": "\u001b[38;2;192;192;192m󰏖  Packages\u001b[0m"
        },
        {
          "type": "shell",
          "key": "\u001b[38;2;192;192;192m  Shell\u001b[0m"
        },
        {
          "type": "display",
          "key": "\u001b[38;2;192;192;192m󰍹  Display\u001b[0m"
        },
        {
          "type": "wm",
          "key": "\u001b[38;2;192;192;192m󱂬  WM\u001b[0m"
        },
        {
          "type": "terminal",
          "key": "\u001b[38;2;192;192;192m  Terminal\u001b[0m"
        },
        {
          "type": "custom",
          "format": "\u001b[38;2;64;64;64m────────────────────────────────────────\u001b[0m"
        },
        {
          "type": "cpu",
          "key": "\u001b[38;2;160;160;160m  CPU\u001b[0m",
          "showPeCoreCount": true,
          "temp": true,
          "format": "{1} ({3}) @ {7} GHz"
        },
        {
          "type": "gpu",
          "key": "\u001b[38;2;160;160;160m󰍲  GPU\u001b[0m",
          "detectionMethod": "pci",
          "format": "{2}"
        },
        {
          "type": "memory",
          "key": "\u001b[38;2;160;160;160m󰘚  Memory\u001b[0m"
        },
        {
          "type": "disk",
          "key": "\u001b[38;2;160;160;160m󰋊  Disk\u001b[0m",
          "folders": "/"
        },
        {
          "type": "battery",
          "key": "\u001b[38;2;160;160;160m󰁹  Battery\u001b[0m"
        },
        {
          "type": "custom",
          "format": "\u001b[38;2;64;64;64m────────────────────────────────────────\u001b[0m"
        },
        {
          "type": "colors",
          "key": "\u001b[38;2;240;240;240m  Colors\u001b[0m",
          "symbol": "circle",
          "paddingLeft": 2
        }
      ]
    }
  '';
  };
}
