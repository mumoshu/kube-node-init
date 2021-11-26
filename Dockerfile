FROM amazonlinux:2

RUN yum update -y && \
    yum install -y systemd chrony curl tar sudo diff && \
    yum clean all

RUN mkdir /tmp/kube-tmp && cd /tmp/kube-tmp && \
    curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    cd / && rm -rf /tmp/kube-tmp

WORKDIR /
