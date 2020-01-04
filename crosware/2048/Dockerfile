#
# 2048 for bash w/netbsdcurses
#

FROM ryanwoodsmall/crosware

ADD https://github.com/mydzor/bash2048/raw/master/bash2048.sh /

RUN chmod 755 /bash2048.sh \
    && ln -sf /bash2048.sh /2048 \
    && . /etc/profile \
    && crosware install netbsdcurses

CMD bash -l -c /2048
    
# vim: set ft=sh:
