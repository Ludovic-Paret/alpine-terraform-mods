FROM alpine:3.7

ARG VERSION_TERRAFORM

COPY ./main.tf /tmp/main.tf
COPY ./terraformrc /root/.terraformrc

ENV TF_PLUGIN_CACHE_DIR "/mods"
 
RUN apk add --update --no-cache curl git bash jq libintl && \
    apk add --virtual build-dependencies gnupg gettext go gcc musl-dev openssl && \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    curl -s https://keybase.io/hashicorp/key.asc | gpg --import && \
    curl -Os https://releases.hashicorp.com/terraform/${VERSION_TERRAFORM}/terraform_${VERSION_TERRAFORM}_linux_amd64.zip && \
    curl -Os https://releases.hashicorp.com/terraform/${VERSION_TERRAFORM}/terraform_${VERSION_TERRAFORM}_SHA256SUMS && \
    curl -Os https://releases.hashicorp.com/terraform/${VERSION_TERRAFORM}/terraform_${VERSION_TERRAFORM}_SHA256SUMS.sig && \
    gpg --verify terraform_${VERSION_TERRAFORM}_SHA256SUMS.sig terraform_${VERSION_TERRAFORM}_SHA256SUMS && \
    sha256sum terraform_${VERSION_TERRAFORM}_SHA256SUMS && \
    unzip terraform_${VERSION_TERRAFORM}_linux_amd64.zip && \
    chmod +x terraform && \
    mv terraform /usr/bin/terraform && \
    export GOPATH=/go && \
    export PATH=${GOPATH}/bin:${PATH} && \
    mkdir -p ${GOPATH}/src ${GOPATH}/bin /mods/linux_amd64 && \
    chmod -R 777 "${GOPATH}" && \
    go get -u github.com/golang/dep/cmd/dep github.com/vmware/terraform-provider-vra7 && \
    cd /go/src/github.com/vmware/terraform-provider-vra7 && \
    dep ensure && \
    go build -o /mods/linux_amd64/terraform-provider-vra7 && \
    cd /tmp && \
    terraform init && \
    apk del build-dependencies && \
    rm -rf /terraform_${VERSION_TERRAFORM}_* /var/cache/apk/* /go /tmp/.terraform /tmp/main.tf

ENTRYPOINT []
