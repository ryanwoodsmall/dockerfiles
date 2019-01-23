# crosware

crosware is a small bash-driven software build system.
it is primarily designed to provide musl-based compilers and a handful of recipes for lower-level userspace and development tools.

this container provides a clean checkout and small userspace for bootstrapping.
the included userspace is completely static and consists of a handful of binaries and their symlinks:

- bash
- busybox
- toybox
- curl
- dropbear

additionally, a fully static gcc+binutils C/C++ toolchain is included.

run ```crosware``` without an arguments to see usage.

## links

- **crosware** - https://github.com/ryanwoodsmall/crosware
- **container** - https://github.com/ryanwoodsmall/crosware#container
