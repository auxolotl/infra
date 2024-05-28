# SPDX-FileCopyrightText: 2024 Auxolotl Infrastructure Contributors
#
# SPDX-License-Identifier: GPL-3.0-only

{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.auxolotl.services.chat;

  matrix-config = {
    "m.server" = "matrix.${cfg.domain}:443";
    "m.homeserver" = {
      base_url = "https://matrix.${cfg.domain}:443";
      server_name = "${cfg.domain}";
    };
  };

  matrix-config-json = pkgs.writeText "matrix-config.json" (builtins.toJSON matrix-config);

  client-config = {
    homeserverList = [
      "https://auxolotl.org"
    ];
    defaultHomeserver = 0;
    allowCustomHomeservers = false;
  };
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
    users = {
      users.pantalaimon-mjolnir = {
        group = "pantalaimon-mjolnir";
        isSystemUser = true;
      };
      groups.pantalaimon-mjolnir = {};
    };

    systemd.services = {
      mjolnir = {
        after = ["conduit.service"];

        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 3;
        };

        unitConfig = {
          StartLimitIntervalSec = 0;
        };
      };

      pantalaimon-mjolnir = {
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "pantalaimon-mjolnir";
          Group = "pantalaimon-mjolnir";
        };
      };
    };

    services.matrix-conduit = {
      enable = true;

      settings = {
        global = {
          server_name = cfg.domain;
          allow_registration = false;
        };
      };
    };

    services.mjolnir = {
      enable = true;

      homeserverUrl = "http://localhost:${builtins.toString config.services.matrix-conduit.settings.global.port}";
      managementRoom = "#mjolnir:${cfg.domain}";

      settings = {
        autojoinOnlyIfManager = true;
        automaticallyRedactForReasons = ["nsfw" "gore" "spam" "harassment" "hate"];
        recordIgnoredInvites = true;
        admin.enableMakeRoomAdminCommand = true;
        allowNoPrefix = false;
        protectedRooms = ["https://matrix.to/#/#general:${cfg.domain}"];
      };

      pantalaimon = {
        enable = true;
        username = "system";
        passwordFile = "/var/lib/secrets/mjolnir-password";
        options = {
          ssl = false;
          listenAddress = "127.0.0.1";
        };
      };
    };

    services.nginx = {
      enable = true;

      virtualHosts = {
        "${cfg.domain}" = {
          locations = {
            "/.well-known/matrix" = {
              root = "/";
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
              root = pkgs.cinny.override {
                conf = client-config;
              };
              tryFiles = "$uri /index.html";
            };
          };
        };

        "matrix.${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;

          locations = {
            "/" = {
              proxyPass = "http://localhost:${builtins.toString config.services.matrix-conduit.settings.global.port}";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
