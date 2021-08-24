#
# XXX - stunnel, rsync, tmux, screen, dtach, links/lynx (w/netbsdcurses?), gnupg, jq, jo, miller
# XXX - tinycc{,mob}, pcc, muslstandalone
# XXX - python, go, ...
#

FROM ryanwoodsmall/crosware:latest

RUN . /etc/profile \
    && export CW_GIT_CMD=git \
    && crosware reinstall bootstrapmake \
    && crosware reinstall make \
    && crosware reinstall byacc \
    && crosware reinstall reflex \
    && crosware reinstall flex \
    && crosware reinstall gitlibressl \
    && crosware update-upgrade-all \
    && crosware reinstall vimnetbsdcurses \
    && crosware reinstall mandoc \
    && crosware reinstall socatlibressl \
    && crosware reinstall heirloom \
    && crosware reinstall baseutils \
    && crosware reinstall outils \
    && crosware reinstall plan9port \
    && uname -m | grep -q '^x86_64$' && crosware reinstall zulu11musl jgitsh habitat || true \
    && crosware reinstall ccache \
    && rm -rf ${cwtop}/downloads/*/*
