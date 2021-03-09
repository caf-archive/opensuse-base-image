#
# Copyright 2017-2020 Micro Focus or one of its affiliates.
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
FROM ${DOCKER_HUB_PUBLIC}/opensuse/leap:latest

# Set the locale manually to a set inherited from the base image (defaults to POSIX)
ENV LANG=en_US.utf8

# Update the OS packages, install cURL, postgreSQL client and dejavu-fonts
RUN zypper -n refresh && \
    zypper -n update && \
    zypper -n install curl postgresql dejavu-fonts && \
    zypper -n clean --all

RUN chmod a+rwx /etc/pki/trust/anchors && \
    chmod -R a+rwx /var/lib/ca-certificates && \
    chmod -R a+rw /etc/ssl

# Add scripts to be executed during startup
COPY startup /startup
ADD https://raw.githubusercontent.com/CAFapi/caf-common/SCMOD-12755/container-cert-script/install-ca-cert.sh \
    /startup/startup.d/install-ca-cert-base.sh
RUN chmod +rx /startup/* /startup/startup.d/* && \
    mkdir -p /tmp/ssl && chmod a+rwx /tmp/ssl

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--", "/startup/startup.sh"]

# Add other useful scripts
COPY scripts /scripts
RUN chmod +x /scripts/*
