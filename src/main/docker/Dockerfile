#
# Copyright 2017-2021 Micro Focus or one of its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ARG DOCKER_HUB_PUBLIC=docker.io
FROM ${DOCKER_HUB_PUBLIC}/opensuse/leap:latest as builder

# Update the OS packages with dirmngr and curl to enable gosu install
RUN zypper -n refresh && \
    zypper -n update && \
    zypper -n install dirmngr curl && \
    zypper -n clean --all

# Install gosu
RUN gpg --batch --keyserver-options http-proxy=${env.HTTP_PROXY} --keyserver hkps://keys.openpgp.org \
      --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.12/gosu-amd64" && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.12/gosu-amd64.asc" && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu

ARG DOCKER_HUB_PUBLIC
FROM ${DOCKER_HUB_PUBLIC}/opensuse/leap:latest

# Set the locale manually to a set inherited from the base image (defaults to POSIX)
ENV LANG=en_US.utf8

# Update the OS packages, install cURL, postgreSQL client and dejavu-fonts
RUN zypper -n refresh && \
    zypper -n update && \
    zypper -n install curl postgresql dejavu-fonts && \
    zypper -n clean --all

# Copy gosu
COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu
RUN chmod +x /usr/local/bin/gosu

# Add scripts to be executed during startup
COPY startup /startup
ADD https://raw.githubusercontent.com/CAFapi/caf-common/v1.19.0/container-cert-script/install-ca-cert.sh \
    /startup/startup.d/install-ca-cert-base.sh
RUN chmod +x /startup/* /startup/startup.d/*

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--", "/startup/startup.sh"]

# Add other useful scripts
COPY scripts /scripts
RUN chmod +x /scripts/*
