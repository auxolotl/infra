{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.auxolotl.services.chat;

  matrix-config = {
    "m.server" = "matrix.${cfg.domain}:443";
  };

  matrix-config-json = pkgs.writeText "matrix-config.json" (builtins.toJSON matrix-config);
in {
  options.auxolotl.services.chat = {
    enable = lib.mkEnableOption "Matrix chat";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "auxolotl.org";
      description = "The domain name for the website.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.matrix-conduit = {
      enable = true;

      settings = {
        global = {
          server_name = cfg.domain;
        };
      };
    };

    services.nginx = {
      enable = true;

      virtualHosts = {
        "${cfg.domain}" = {
          locations = {
            "/.well-known/matrix/server" = {
              tryFiles = "${matrix-config-json} =404";

              extraConfig = ''
                add_header Access-Control-Allow-Origin *;
              '';
            };
          };
        };

        "chat.${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;

          locations = {
            "/" = {
              root = pkgs.cinny;
            };
          };
        };

        "matrix.${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = "http://localhost:${config.services.matrix-conduit.settings.global.port}";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
