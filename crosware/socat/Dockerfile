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
