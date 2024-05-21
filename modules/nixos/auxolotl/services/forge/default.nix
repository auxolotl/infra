{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.auxolotl.services.forge;
in {
  options.auxolotl.services.forge = {
    enable = lib.mkEnableOption "Forge";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "auxolotl.org";
      description = "The domain name for the website.";
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "git";
      description = "The subdomain for the website.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "The port for Forgejo to listen on.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;

      lfs.enable = true;

      mailerPasswordFile = "/var/lib/secrets/forgejo-smtp-password";

      database = {
        type = "postgres";
      };

      settings = {
        DEFAULT = {
          APP_NAME = "Auxolotl Forge";
        };
        cron = {
          ENABLE = true;
          RUN_AT_START = true;
        };
        mailer = {
          ENABLED = true;
          FROM = "git@${cfg.domain}";
          PROTOCOL = "smtps";
          SMTP_ADDR = "smtp.mailgun.org";
          SMTP_PORT = 465;
          USER = "git@${cfg.domain}";
        };
        service = {
          ENABLE_CAPTCHA = true;
          ENABLE_BASIC_AUTHENTICATION = false;
          REGISTER_EMAIL_CONFIRM = true;
          ENABLE_NOTIFY_MAIL = true;
          DISABLE_REGISTRATION = false;
          DEFAULT_ALLOW_CREATE_ORGANIZATION = false;
        };
        server = {
          DOMAIN = "${cfg.subdomain}.${cfg.domain}";
          HTTP_PORT = cfg.port;
          ROOT_URL = "https://${cfg.subdomain}.${cfg.domain}";
        };
        repository = {
          ENABLE_PUSH_CREATE_USER = true;
          ENABLE_PUSH_CREATE_ORG = true;
        };
        security = {
          INSTALL_LOCK = true;
        };
        indexer = {
          REPO_INDEXER_ENABLED = true;
        };
        session = {
          PROVIDER = "db";
        };
        "repository.pull-request" = {
          DEFAULT_MERGE_STYLE = "squash";
        };
        "repository.signing" = {
          DEFAULT_TRUST_MODEL = "committer";
        };
      };
    };

    services.nginx = {
      enable = true;

      virtualHosts = {
        "${cfg.subdomain}.${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;

          locations = {
            "/" = {
              proxyPass = "http://localhost:${builtins.toString cfg.port}";
            };
          };
        };
      };
    };
  };
}
