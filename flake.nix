{
  description = "Auxolotl infrastructure.";

  inputs = {
    nixpkgs.url = "github:auxolotl/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auxolotl-website = {
      url = "github:auxolotl/website";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;

      src = ./.;

      overlays = with inputs; [
        auxolotl-website.overlays.default
      ];
    };
}
