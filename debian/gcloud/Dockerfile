FROM debian:bookworm

# base setup
RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get autoremove -y \
    && apt full-upgrade -y \
    && apt install -y curl wget sudo tini vim-nox file jq screen less busybox openssh-client dropbear-bin \
    && groupadd -g 1000 user \
    && useradd -m -d /home/user -s /bin/bash -g 1000 -u 1000 user \
    && echo 'user ALL=(ALL:ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/zz_local

# https://cloud.google.com/sdk/docs/install#deb
RUN apt install -y apt-transport-https ca-certificates gnupg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update -y \
    && apt-get install google-cloud-cli -y \
    && apt-get install -y google-cloud-cli-gke-gcloud-auth-plugin kubectl

# runtime setup
USER user
WORKDIR /home/user
ENTRYPOINT ["/usr/bin/tini-static", "-gwvv","--"]
CMD ["/bin/bash","-il"]
