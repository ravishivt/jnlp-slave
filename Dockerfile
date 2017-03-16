# https://hub.docker.com/r/jenkinsci/jnlp-slave/
FROM jenkinsci/jnlp-slave:2.62-alpine
MAINTAINER GitHub ravishivt

ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/ravishivt/jnlp-slave" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.docker.dockerfile="/Dockerfile"

# The default user for base image is not root.  We also need to update the $HOME directory for pip cache.
USER root
ENV HOME /root

ENV HELM_VERSION v2.1.3
ENV KUBECTL_VERSION v1.5.2

RUN \
  # Install curl-dev on alpine 3.4 due to http://stackoverflow.com/a/41651363/684893
  apk add --no-cache docker curl curl-dev openssh gettext \
  # Use latest GNU tar since busybox tar version is missing useful features.
  && apk --update add tar \
  # Install Helm
  && curl -fsSL -o helm.tar.gz https://kubernetes-helm.storage.googleapis.com/helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && tar -C /usr/local/ -xzf helm.tar.gz \
  && cp /usr/local/linux-amd64/helm /usr/local/bin/ \
  # Install kubectl as per https://kubernetes.io/docs/user-guide/prereqs/
  # && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
  && curl -fsSLO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl \
  && mv ./kubectl /usr/local/bin/kubectl \
  # Install Python and NodeJS base dependencies and build dependencies.
  && apk add --no-cache python py-psycopg2 py-pip jpeg-dev nodejs \
  && apk add --no-cache --virtual .build-dependencies python-dev build-base git \
    zlib-dev libmemcached-dev cyrus-sasl-dev jq \
  # Create a python virtualenv for future caching purposes.  Don't actually create a virtualenv yet because then we can't cache the pip packages.
  && pip install --upgrade pip virtualenv \
  # Install yarn through deprecated npm method.
  #   Alpine will have a yarn package in future, https://pkgs.alpinelinux.org/packages?name=yarn&branch=&repo=&arch=&maintainer=
  && npm install -g yarn --quiet --progress=false --color false \
  # Cleanup
  && rm -rf /var/cache/apk/*

ENV LANG=C.UTF-8 VIRTUAL_ENV=/root/venv PATH=/root/venv/bin:$PATH PYTHONPATH=/usr/lib/python2.7/site-packages/

WORKDIR /root/app

