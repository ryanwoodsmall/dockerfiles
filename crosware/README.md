# crosware

crosware is a small bash-driven software build system.
it is primarily designed to provide musl-based compilers and a handful of recipes for lower-level userspace and development tools.

this container provides a clean checkout and small userspace for bootstrapping. the included userspace is completely static and consists of a handful of packages:

- bash
- busybox
- toybox
- curl

run ```crosware``` without an arguments to see usage.
to install the base compiler, run ```crosare install statictoolchain```.

## links

- **crosware** - https://github.com/ryanwoodsmall/crosware
- **container** - https://github.com/ryanwoodsmall/crosware#container
