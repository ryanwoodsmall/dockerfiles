#
# build:
#   docker build --tag socat https://github.com/ryanwoodsmall/dockerfiles/raw/master/crosware/socat/Dockerfile
# expose docker socket insecurely on tcp 2375:
#   docker run -d --restart always --name socat-docker -it -p 2375:2375 -v /var/run/docker.sock:/docker.sock socat -d -d tcp4-listen:2375,fork,reuseaddr unix-connect:/docker.sock
#   curl -s --unix-socket /var/run/docker.sock http/info
#   curl -kLs http://localhost:2375/info
# expose remote docker registry locally to get around having certs, which is insane:
#   docker run -d --restart always -it -p 5000:5000 --name socat-registry -p 5001:5000 socat -d -d tcp-listen:5000,fork,reuseaddr tcp-connect:123.45.67.89:5000
# decap ssh encapsulated in https with openssl to defeat protocol checks:
#   socat -d tcp4-listen:33333,fork,reuseaddr exec:'openssl s_client -connect remote.https-ssh.hostname\:443'
#   # without local stunnel - fine for quick/dirty connections but heartbeat kills connection?
# bind localhost-only dropbear ssh on port 2222 to a specific host ip
#   docker run -d -it --restart always --network host --name socat-dropbear socat -d -d tcp4-listen:2222,fork,reuseaddr,bind=192.168.100.1 tcp4-connect:127.0.0.1:2222
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
COPY --from=SOCATBUILDER /etc/group /etc/
COPY --from=SOCATBUILDER /etc/passwd /etc/
COPY --from=SOCATBUILDER /etc/shadow /etc/
ENTRYPOINT ["/socat"]

# vim: set ft=sh:
