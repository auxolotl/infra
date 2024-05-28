# SPDX-FileCopyrightText: 2024 Auxolotl Infrastructure Contributors
#
# SPDX-License-Identifier: GPL-3.0-only

{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.auxolotl.security.doas;
in {
  options.auxolotl.security.doas = {
    enable = lib.mkEnableOption "doas";
  };

  config = lib.mkIf cfg.enable {
    security.sudo.enable = false;

    security.doas = {
      enable = true;
      extraRules = lib.optional config.auxolotl.users.infra.enable {
        users = ["infra"];
        noPass = true;
        keepEnv = true;
      };
    };

    environment.shellAliases = {
      sudo = "doas";
    };
  };
}
