#
# build and install up-to-date autotools on an out-of-date operating system
#

# https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz
# https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.gz
# https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz

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

ENV libtoolver=2.4.6
ENV libtooldir=libtool-${libtoolver}
ENV libtoolfile=${libtooldir}.tar.gz
ENV libtoolurl=https://ftp.gnu.org/gnu/libtool/${libtoolfile}
ENV libtoolsha256=e3bd4d5d3d025a36c21dd6af7ea818a2afcd4dfc1ea5a17b39d7854bcd0c06e3

RUN echo 'installing prereqs' \
    && yum clean all \
    && yum list updates \
    && yum -y update \
    && yum -y install make perl gcc gcc-c++ m4 autoconf automake libtool curl wget which openssh-clients \
    && yum --enablerepo=* clean all

RUN echo 'build autotools' \
    && export td=${autotoolsdir} \
    && export PATH=${td}/bin:${PATH} \
    && export bd=${td}/build \
    && export dld=${td}/download \
    && mkdir -p ${bd} \
    && mkdir -p ${dld} \
    && for u in ${autoconfurl} ${automakeurl} ${libtoolurl} ; do ( cd ${dld} ; curl -kLO ${u} ) ; done \
    && for s in ${autoconfsha256} ${automakesha256} ${libtoolsha256} ; do ( cd ${dld} ; sha256sum * | grep ^${s} ) ; done \
    && for f in ${autoconffile} ${automakefile} ${libtoolfile} ; do ( cd ${dld} ; tar -C ${bd} -zxf ${f} ) ; done \
    && for d in ${autoconfdir} ${automakedir} ${libtooldir} ; do for n in {1..3} ; do ( cd ${bd}/${d} ; make clean ; make distclean ; ./configure --prefix=${td} && make && make install ) ; done ; done \
    && which -a autoconf automake libtool \
    && echo export PATH=${td}/bin:\${PATH} | tee /etc/profile.d/zz_autotools.sh \
    && grep -Hi . /etc/profile.d/zz_autotools.sh \
    && rm -rf ${bd}
