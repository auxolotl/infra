{
  lib,
  config,
  ...
}: let
  cfg = config.auxolotl.users.infra;
in {
  options.auxolotl.users.infra = {
    enable = lib.mkEnableOption "Infra user";
  };

  config = lib.mkIf cfg.enable {
    users.users.infra = {
      isNormalUser = true;
      description = "Infra user";

      home = "/home/infra";
      createHome = true;

      extraGroups = ["wheel"];

      openssh.authorizedKeys.keys = [
        # jakehamilton
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwaaCUq3Ooq1BaHbg5IwVxWj/xmNJY2dDthHKPZefrHXv/ksM/IREgm38J0CdoMpVS0Zp1C/vFrwGfaYZ2lCF5hBVdV3gf+mvj8Yb8Xpm6aM4L5ig+oBMp/3cz1+g/I4aLMJfCKCtdD6Q2o4vtkTpid6X+kL3UGZbX0HFn3pxoDinzOXQnVGSGw+pQhLASvQeVXWTJjVfIWhj9L2NRJau42cBRRlAH9kE3HUbcgLgyPUZ28aGXLLmiQ6CUjiIlce5ee16WNLHQHOzVfPJfF1e1F0HwGMMBe39ey3IEQz6ab1YqlIzjRx9fQ9hQK6Du+Duupby8JmBlbUAxhh8KJFCJB2cXW/K5Et4R8GHMS6MyIoKQwFUXGyrszVfiuNTGZIkPAYx9zlCq9M/J+x1xUZLHymL85WLPyxhlhN4ysM9ILYiyiJ3gYrPIn5FIZrW7MCQX4h8k0bEjWUwH5kF3dZpEvIT2ssyIu12fGzXkYaNQcJEb5D9gT1mNyi2dxQ62NPZ5orfYyIZ7fn22d1P/jegG+7LQeXPiy5NLE6b7MP5Rq2dL8Y9Oi8pOBtoY9BpLh7saSBbNFXTBtH/8OfAQacxDsZD/zTFtCzZjtTK6yiAaXCZTvMIOuoYGZvEk6zWXrjVsU8FlqF+4JOTfePqr/SSUXNJyKnrvQJ1BfHQiYsrckw=="
      ];
    };

    nix.settings = {
      trusted-users = ["infra"];
      allowed-users = ["infra"];
    };
  };
}
