{
  description = "Auxolotl infrastructure.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auxolotl-website = {
      url = "github:auxolotl/website";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;

      src = ./.;

      snowfall = {
        namespace = "auxolotl";
      };
    };
  in
    lib.mkFlake {
      overlays = with inputs; [
        auxolotl-website.overlays.default
      ];

      deploy = lib.mkDeploy {
        inherit (inputs) self;
      };

      checks =
        builtins.mapAttrs
        (system: deploy-lib: deploy-lib.deployChecks inputs.self.deploy)
        inputs.deploy-rs.lib;
    };
}
