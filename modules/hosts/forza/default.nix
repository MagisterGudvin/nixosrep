{ self, inputs, ... }: {
  flake.nixosConfigurations.forza = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.forzaConfiguration
    ];
  };
}
