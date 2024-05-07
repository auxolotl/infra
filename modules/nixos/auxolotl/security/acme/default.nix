{
  lib,
  config,
  ...
}: let
  cfg = config.auxolotl.security.acme;
in {
  options.auxolotl.security.acme = {
    enable = lib.mkEnableOption "Acme defaults";

    email = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Email address to use for Let's Encrypt registration.";
    };

    staging = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use the Let's Encrypt staging server.";
    };
  };

  config = lib.mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;

      defaults = {
        inherit (cfg) email;

        group = lib.mkIf config.services.nginx.enable "nginx";
        server = lib.mkIf cfg.staging "https://acme-staging-v02.api.letsencrypt.org/directory";

        # Reload nginx when certs change.
        reloadServices = lib.optional config.services.nginx.enable "nginx.service";
      };
    };
  };
}
