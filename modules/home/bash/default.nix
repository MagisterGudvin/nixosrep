{ ... }: {
  flake.homeModules.bash = { pkgs, ... }: {
    programs.starship.enable = true;

    programs.bash = {
      enable = true;

      shellAliases = {
        ff = "clear && fastfetch";
        fm = "yazi";
        cdlw = "cd /run/media/gooblin/lw";
      };

      bashrcExtra = ''
        if [[ $- == *i* ]]; then
          fastfetch
        fi
      '';
    };

    home.sessionVariables = {
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
      PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
      PRISMA_FMT_BINARY = "${pkgs.prisma-engines}/bin/prisma-fmt";
    };
  };
}
