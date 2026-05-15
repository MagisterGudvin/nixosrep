{ self, inputs, ... }: {
  flake.nixosConfigurations.Forza = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.ForzaConfiguration
    ];
  };
}
