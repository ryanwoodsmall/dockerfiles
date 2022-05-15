FROM ryanwoodsmall/crosware

RUN cd /usr/bin \
    && toybox find . -type l | xargs toybox rm -f \
    && toybox rm -f busybox \
    && for a in $(./toybox) ; do test -e "${a}" || toybox ln -s toybox "${a}" ; done

# vim: ft=dockerfile:
