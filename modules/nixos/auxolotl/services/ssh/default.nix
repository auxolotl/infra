{
  lib,
  config,
  ...
}: let
  cfg = config.auxolotl.services.ssh;
in {
  options.auxolotl.services.ssh = {
    enable = lib.mkEnableOption "SSH";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
    };
  };
}
