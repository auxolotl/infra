{
  lib,
  inputs,
}: let
  inherit (inputs) deploy-rs;
in rec {
  ## Create deployment configuration for use with deploy-rs.
  ##
  ## ```nix
  ## mkDeploy {
  ##   inherit self;
  ##   overrides = {
  ##     my-host.system.sudo = "doas -u";
  ##   };
  ## }
  ## ```
  ##
  #@ { self: Flake, overrides: Attrs ? {} } -> Attrs
  mkDeploy = {
    self,
    overrides ? {},
  }: let
    hosts = self.nixosConfigurations or {};
    names = builtins.attrNames hosts;
    nodes =
      lib.foldl
      (result: name: let
        host = hosts.${name};
        user = host.config.users.infra or null;
        inherit (host.pkgs) system;
      in
        result
        // {
          ${name} =
            (overrides.${name} or {})
            // {
              hostname = overrides.${name}.hostname or "${name}";
              profiles =
                (overrides.${name}.profiles or {})
                // {
                  system =
                    (overrides.${name}.profiles.system or {})
                    // {
                      path = deploy-rs.lib.${system}.activate.nixos host;
                    }
                    // {
                      user = "root";
                      sshUser = "infra";
                    }
                    // lib.optionalAttrs host.config.auxolotl.security.doas.enable {
                      sudo = "doas -u";
                    };
                };
            };
        })
      {}
      names;
  in {inherit nodes;};
}
