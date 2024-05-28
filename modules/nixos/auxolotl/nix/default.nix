# SPDX-FileCopyrightText: 2024 Auxolotl Infrastructure Contributors
#
# SPDX-License-Identifier: GPL-3.0-only

{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.auxolotl.nix;

  substituters-submodule = lib.types.submodule ({name, ...}: {
    options = {
      key = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The trusted public key for this substituter.";
      };
    };
  });
in {
  options.auxolotl.nix = {
    enable = lib.mkEnableOption "Nix configuration";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nix;
      defaultText = "pkgs.nix";
      description = "Which Nix package to use.";
    };

    default-substituter = {
      url = lib.mkOption {
        type = lib.types.str;
        default = "https://cache.nixos.org";
        description = "The url for the substituter.";
      };
      key = lib.mkOption {
        type = lib.types.str;
        default = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
        description = "The trusted public key for the substituter.";
      };
    };

    extra-substituters = lib.mkOption {
      type = lib.types.attrsOf substituters-submodule;
      default = {};
      description = "Extra substituters to configure.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      lib.mapAttrsToList
      (name: value: {
        assertion = value.key != null;
        message = "auxolotl.nix.extra-substituters.${name}.key must be set";
      })
      cfg.extra-substituters;

    nix = let
      users = ["root"];
    in {
      package = cfg.package;

      settings = {
        experimental-features = "nix-command flakes";
        http-connections = 50;
        log-lines = 50;
        auto-optimise-store = true;

        trusted-users = users;
        allowed-users = users;

        substituters =
          [cfg.default-substituter.url]
          ++ (lib.mapAttrsToList (name: value: name) cfg.extra-substituters);

        trusted-public-keys =
          [cfg.default-substituter.key]
          ++ (lib.mapAttrsToList (name: value: value.key) cfg.extra-substituters);
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      # flake-utils-plus
      generateRegistryFromInputs = true;
      generateNixPathFromInputs = true;
      linkInputs = true;
    };
  };
}
