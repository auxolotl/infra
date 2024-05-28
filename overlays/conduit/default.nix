# SPDX-FileCopyrightText: 2024 Auxolotl Infrastructure Contributors
#
# SPDX-License-Identifier: GPL-3.0-only

{channels, ...}: final: prev: {
  inherit (channels.unstable) matrix-conduit;
}
