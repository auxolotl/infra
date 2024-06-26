# axol
# 137.184.177.239
{
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];

  boot.loader.grub.enable = true;

  virtualisation.digitalOcean.rebuildFromUserData = false;

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  environment.systemPackages = with pkgs; [
    neovim
  ];

  auxolotl = {
    nix.enable = true;

    users.infra.enable = true;

    security = {
      doas.enable = true;

      acme = {
        enable = true;
        email = "jake.hamilton@hey.com";
      };
    };

    services = {
      chat.enable = true;
      website.enable = true;
    };
  };

  system.stateVersion = "23.11";
}
