FROM debian:trixie

# base setup
RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get autoremove -y \
    && apt full-upgrade -y \
    && apt install -y \
       busybox \
       curl \
       dropbear-bin \
       file \
       gojq \
       golang-github-pelletier-go-toml \
       jo \
       jq \
       less \
       libxml2-utils \
       moreutils \
       openssh-client \
       procps \
       psmisc \
       rlwrap \
       screen \
       sudo \
       tidy \
       tini \
       tmux \
       unzip \
       vim-nox \
       wget \
       xmlstarlet \
       xz-utils \
       yq \
       zip \
    && apt purge -y nano vim-tiny || true \
    && groupadd -g 1000 user \
    && useradd -m -d /home/user -s /bin/bash -g 1000 -u 1000 user \
    && echo 'user ALL=(ALL:ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/zz_local

# https://cloud.google.com/sdk/docs/install#deb
RUN apt install -y apt-transport-https ca-certificates gnupg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
       | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
       | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && apt-get update -y \
    && apt-get install google-cloud-cli -y \
    && apt-get install -y google-cloud-cli-gke-gcloud-auth-plugin kubectl \
    && gcloud config set survey/disable_prompts True

# runtime setup
USER user
WORKDIR /home/user
ENTRYPOINT ["/usr/bin/tini-static", "-gwvv","--"]
CMD ["/bin/bash","-il"]
