#
# build and install up-to-date autotools on an out-of-date operating system
#
# XXX - need ed? make? sed? gawk? coreutils?
# XXX - make an RPM?
#

FROM oraclelinux:7

ENV autotoolsdir=/opt/autotools
ENV gnudl=https://ftp.gnu.org/gnu

ENV autoconfver=2.72
ENV autoconfdir=autoconf-${autoconfver}
ENV autoconffile=${autoconfdir}.tar.gz
ENV autoconfurl=${gnudl}/autoconf/${autoconffile}
ENV autoconfsha256=afb181a76e1ee72832f6581c0eddf8df032b83e2e0239ef79ebedc4467d92d6e

ENV automakever=1.17
ENV automakedir=automake-${automakever}
ENV automakefile=${automakedir}.tar.gz
ENV automakeurl=${gnudl}/automake/${automakefile}
ENV automakesha256=397767d4db3018dd4440825b60c64258b636eaf6bf99ac8b0897f06c89310acd

ENV libtoolver=2.5.3
ENV libtooldir=libtool-${libtoolver}
ENV libtoolfile=${libtooldir}.tar.gz
ENV libtoolurl=${gnudl}/libtool/${libtoolfile}
ENV libtoolsha256=9322bd8f6bc848fda3e385899dd1934957169652acef716d19d19d24053abb95

ENV m4ver=1.4.19
ENV m4dir=m4-${m4ver}
ENV m4file=${m4dir}.tar.gz
ENV m4url=${gnudl}/m4/${m4file}
ENV m4sha256=3be4a26d825ffdfda52a56fc43246456989a3630093cced3fbddf4771ee58a70

ENV pkgconfigver=0.29.2
ENV pkgconfigdir=pkg-config-${pkgconfigver}
ENV pkgconfigfile=${pkgconfigdir}.tar.gz
ENV pkgconfigurl=https://pkgconfig.freedesktop.org/releases/${pkgconfigfile}
ENV pkgconfigsha256=6fc69c01688c9458a57eb9a1664c9aba372ccda420a02bf4429fe610e7e7d591

RUN echo 'installing prereqs' \
    && yum clean all \
    && yum list updates \
    && yum -y update \
    && yum -y install make perl gcc gcc-c++ m4 autoconf automake libtool curl wget which openssh-clients diffutils patch xz bzip2 git file vim-enhanced \
    && yum -y install rpm-build rpm rpmdevtools glibc-static \
    && yum --enablerepo=* clean all

RUN echo 'build autotools' \
    && export td=${autotoolsdir} \
    && export PATH=${td}/bin:${PATH} \
    && export bd=${td}/build \
    && export dld=${td}/download \
    && mkdir -p ${bd} \
    && mkdir -p ${dld} \
    && for u in ${autoconfurl} ${automakeurl} ${libtoolurl} ${pkgconfigurl} ${m4url} ; do ( cd ${dld} ; curl -kLO ${u} ) ; done \
    && for s in ${autoconfsha256} ${automakesha256} ${libtoolsha256} ${pkgconfigsha256} ${m4sha256} ; do ( cd ${dld} ; sha256sum * | grep ^${s} ) ; done \
    && for f in ${autoconffile} ${automakefile} ${libtoolfile} ${pkgconfigfile} ${m4file} ; do ( cd ${dld} ; if [[ ${f} =~ gz$ ]] ; then gzip -dc ${f} ; else xzcat ${f} ; fi | tar -C ${bd} -xf - ) ; done \
    && for d in ${autoconfdir} ${automakedir} ${libtooldir} ${m4dir} ; do for n in {1..3} ; do ( cd ${bd}/${d} ; make clean ; make distclean ; ./configure --prefix=${td} && make && make install ) ; done ; done \
    && ( cd ${bd}/${pkgconfigdir} ; ./configure --prefix=${td} --with-internal-glib --with-system-library-path="${td}/lib:/lib:/lib64:/usr/lib:/usr/lib64" && make && make install ) \
    && which -a autoconf automake libtool pkg-config m4 \
    && echo export PATH=${td}/bin:\${PATH} | tee /etc/profile.d/zz_autotools.sh \
    && grep -Hi . /etc/profile.d/zz_autotools.sh \
    && rm -rf ${bd}
