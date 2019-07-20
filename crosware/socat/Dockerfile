#
# expose docker socket insecurely on tcp 2375:
#   docker build --tag socat https://github.com/ryanwoodsmall/dockerfiles/raw/master/crosware/socat/Dockerfile
#   docker run -it --rm -p 2375:2375 -v /var/run/docker.sock:/docker.sock socat -v -d -d tcp4-listen:2375,fork,reuseaddr unix-connect:/docker.sock
#   curl -s --unix-socket /var/run/docker.sock http/info
#   curl -kLs http://localhost:2375/info
# decap ssh encapsulated in https with openssl to defeat protocol checks:
#   socat -d tcp4-listen:33333,fork,reuseaddr exec:'openssl s_client -connect remote.https-ssh.hostname\:443'
#   # without local stunnel - fine for quick/dirty connections but heartbeat kills connection?
#

FROM ryanwoodsmall/crosware:latest as SOCATBUILDER
RUN source /usr/local/crosware/etc/profile \
    && socatrecipe="${cwtop}/recipes/socat/socat.sh" \
    && sed -i.ORIG '/--enable-openssl/d'  ${socatrecipe} \
    && sed -i      '/--enable-readline/d' ${socatrecipe} \
    && sed -i      's/LIBS=.*/DUMMY=""/g' ${socatrecipe} \
    && sed -i      's/openssl//g'         ${socatrecipe} \
    && sed -i      's/readline//g'        ${socatrecipe} \
    && diff -Naur ${socatrecipe}{.ORIG,} || true \
    && crosware install socat \
    && source /usr/local/crosware/etc/profile \
    && cat ${socatrecipe}.ORIG > ${socatrecipe} \
    && rm -f ${socatrecipe}.ORIG \
    && rm -rf /stow/ \
    && mkdir -p /stow \
    && cp /usr/local/crosware/software/socat/current/bin/socat /stow/ \
    && strip --strip-all /stow/socat

FROM scratch
COPY --from=SOCATBUILDER /stow/socat /socat
ENTRYPOINT ["/socat"]

# vim: set ft=sh:
