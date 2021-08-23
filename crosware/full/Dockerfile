FROM ryanwoodsmall/crosware:latest

RUN . /etc/profile \
    && export CW_GIT_CMD=git \
    && time crosware reinstall gitlibressl \
    && time crosware update-upgrade-all \
    && time crosware reinstall vimnetbsdcurses \
    && time crosware reinstall ccache \
    && find ${cwtop}/downloads/*/ -type f -exec rm -f {} +
