{ lib, ... }: {
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = { };
    description = ''
      Home-Manager modules exported by this flake. Declared here so
      flake-parts knows to merge per-file `flake.homeModules.<name>`
      definitions across modules/ instead of treating them as
      conflicting whole-attrset assignments.
    '';
  };
}
