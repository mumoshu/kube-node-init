FROM amazonlinux:2

LABEL maintainer "Yusuke Kuoka <ykuoka@gmail.com>"

RUN yum update -y && \
    yum install -y systemd chrony curl tar sudo diff

RUN mkdir work && cd work && \
    curl -L https://dl.k8s.io/v1.11.5/kubernetes-client-linux-amd64.tar.gz -o temp.tgz && \
    tar zxvf temp.tgz && \
    mv kubernetes/client/bin/kubectl /usr/bin/kubectl && \
    cd .. && \
    rm -rf work

RUN curl -L https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64 -o /usr/bin/aws-iam-authenticator && \
    chmod +x /usr/bin/aws-iam-authenticator

WORKDIR /
