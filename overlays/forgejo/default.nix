# SPDX-FileCopyrightText: 2024 Auxolotl Infrastructure Contributors
#
# SPDX-License-Identifier: GPL-3.0-only

{...}: final: prev: {
  forgejo = prev.forgejo.overrideAttrs (prevAttrs: {
    patches = (prevAttrs.patches or []) ++ [
      ./map-non-existant-external-users-to-ghost.patch
    ];
  });
}
