#
# build and install up-to-date autotools on an out-of-date operating system
#
# https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz
# https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.gz
# https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz
#
# XXX - need m4? ed? make? sed? gawk? coreutils?
# XXX - make an RPM?
#

FROM centos:7

ENV autotoolsdir=/opt/autotools

ENV autoconfver=2.71
ENV autoconfdir=autoconf-${autoconfver}
ENV autoconffile=${autoconfdir}.tar.gz
ENV autoconfurl=https://ftp.gnu.org/gnu/autoconf/${autoconffile}
ENV autoconfsha256=431075ad0bf529ef13cb41e9042c542381103e80015686222b8a9d4abef42a1c

ENV automakever=1.16.5
ENV automakedir=automake-${automakever}
ENV automakefile=${automakedir}.tar.gz
ENV automakeurl=https://ftp.gnu.org/gnu/automake/${automakefile}
ENV automakesha256=07bd24ad08a64bc17250ce09ec56e921d6343903943e99ccf63bbf0705e34605

ENV libtoolver=2.4.7
ENV libtooldir=libtool-${libtoolver}
ENV libtoolfile=${libtooldir}.tar.xz
ENV libtoolurl=https://ftp.gnu.org/gnu/libtool/${libtoolfile}
ENV libtoolsha256=4f7f217f057ce655ff22559ad221a0fd8ef84ad1fc5fcb6990cecc333aa1635d

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
    && for u in ${autoconfurl} ${automakeurl} ${libtoolurl} ${pkgconfigurl} ; do ( cd ${dld} ; curl -kLO ${u} ) ; done \
    && for s in ${autoconfsha256} ${automakesha256} ${libtoolsha256} ${pkgconfigsha256} ; do ( cd ${dld} ; sha256sum * | grep ^${s} ) ; done \
    && for f in ${autoconffile} ${automakefile} ${libtoolfile} ${pkgconfigfile} ; do ( cd ${dld} ; if [[ ${f} =~ gz$ ]] ; then gzip -dc ${f} ; else xzcat ${f} ; fi | tar -C ${bd} -xf - ) ; done \
    && for d in ${autoconfdir} ${automakedir} ${libtooldir} ; do for n in {1..3} ; do ( cd ${bd}/${d} ; make clean ; make distclean ; ./configure --prefix=${td} && make && make install ) ; done ; done \
    && ( cd ${bd}/${pkgconfigdir} ; ./configure --prefix=${td} --with-internal-glib --with-system-library-path="${td}/lib:/lib:/lib64:/usr/lib:/usr/lib64" && make && make install ) \
    && which -a autoconf automake libtool pkg-config \
    && echo export PATH=${td}/bin:\${PATH} | tee /etc/profile.d/zz_autotools.sh \
    && grep -Hi . /etc/profile.d/zz_autotools.sh \
    && rm -rf ${bd}
