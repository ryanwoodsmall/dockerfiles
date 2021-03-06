#
# start crosware container dropbear
#   docker build --tag ryanwoodsmall/crosware:dropbear .
#   docker run -it -p 2222:2222 ryanwoodsmall/crosware:dropbear
#
# XXX - limit length/alphanumeric chars: tr -cd "[[:alnum:]]" | cut -c1-16
#

FROM ryanwoodsmall/crosware

EXPOSE 2222

RUN . /etc/profile \
    && for r in tini dropbear ; do crosware check-installed ${r} || crosware install ${r} ; done \
    && install -m 0755 ${cwsw}/tini/current/sbin/tini /usr/sbin/tini \
    && touch /entrypoint.sh \
    && chmod 755 /entrypoint.sh \
    && echo '#!/usr/bin/env bash' >> /entrypoint.sh \
    && echo '#set -x' >> /entrypoint.sh \
    && echo '. /etc/profile' >> /entrypoint.sh \
    && echo 'RI="${RANDOM}$(date +%Y%m%d%H%M%S)${RANDOM}"' >> /entrypoint.sh \
    && echo 'grep -q "^root:\*:" /etc/shadow && { GP="$(echo ${RI} | base64)" && echo "${GP}" > "${HOME}/generated.passwd" && echo "root:${GP}" | chpasswd ; }'  >> /entrypoint.sh \
    && echo 'test -e "${HOME}/generated.passwd" && cat "${HOME}/generated.passwd" | dos2unix' >> /entrypoint.sh \
    && echo 'exec dropbear -R -F -E -B' >> /entrypoint.sh

ENTRYPOINT ["/usr/sbin/tini","-gwvv","--"]

CMD ["bash","/entrypoint.sh"]
