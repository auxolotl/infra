# SPDX-FileCopyrightText: 2024 Auxolotl Infrastructure Contributors
#
# SPDX-License-Identifier: GPL-3.0-only

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
