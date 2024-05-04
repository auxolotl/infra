{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.auxolotl.services.website;
in {
  options.auxolotl.services.website = {
    enable = lib.mkEnableOption "Auxolotl website";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "auxolotl.org";
      description = "The domain name for the website.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.aux.website;
      defaultText = "pkgs.aux.website";
      description = "The website files to serve.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;

      virtualHosts."${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;

        locations = {
          "/" = {
            root = cfg.package;
          };
        };
      };
    };
  };
}
