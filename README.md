> [!WARNING]
> **This repository has moved!**<br/>
> You can contribute or find up-to-date content at https://git.auxolotl.org/auxolotl/infra

# Auxolotl - Infrastructure

<a href="https://forum.aux.computer/c/committees/infrastructure-committee/29"><img src="https://img.shields.io/static/v1?label=Maintained%20By&message=Infrastructure%20Committee&style=for-the-badge&labelColor=222222&color=794AFF" /></a>

This repository contains system configuration for Auxolotl's infrastructure.

## Access

To gain access to a system for administration, create a pull request adding your public SSH key
to [the known keys list for the `infra` user](./modules/nixos/auxolotl/users/infra/default.nix). The
pull request description should include information explaining why you need direct access to the
machine.

Once your pull request has been accepted you can access the machine by running `ssh infra@<ip>` where
the IP can be found in the following section's systems list.

## Systems

| System                                          | Description                                                   | IP                |
| ----------------------------------------------- | ------------------------------------------------------------- | ----------------- |
| [axol](./systems/x86_64-linux/axol/default.nix) | Primary server hosting `auxolotl.org` and `chat.auxolotl.org` | `137.184.177.239` |
