{
  mkShell,
  reuse,
  deploy-rs,
}:
mkShell {
  packages = [
    reuse # Used to provide licenses & copyright attribution
    deploy-rs # Used to deploy to our servers
  ];
}
