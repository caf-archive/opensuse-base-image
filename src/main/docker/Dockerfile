#
# Copyright 2017-2024 Open Text.
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

# Docker registry
ARG DOCKER_HUB_PUBLIC=docker.io

#
# Stage 1: The start of the actual image definition
# - Install desired packages
# - Specify policy for cryptographic back-ends
#
FROM ${DOCKER_HUB_PUBLIC}/opensuse/leap:latest AS stage1

# Set the locale manually to a set inherited from the base image (defaults to POSIX)
ENV LANG=en_US.utf8

# Copy custom crypto-policy file
COPY DISABLE-CBC.pmod /etc/crypto-policies/policies/modules

# Update the OS packages, install cURL, postgreSQL client and dejavu-fonts
# Install crypto-policies-scripts and disable weaker security algorithms
RUN zypper -n refresh && \
    zypper -n update && \
    zypper -n install curl postgresql dejavu-fonts crypto-policies-scripts && \
    update-crypto-policies --set DEFAULT:DISABLE-CBC && \
    sed -rie '/^jdk.tls.disabledAlgorithms=/s/$/, TLS_DHE_RSA_WITH_CHACHA20_POLY1305_SHA256/' \
        /etc/crypto-policies/back-ends/java.config && \
    zypper -n remove -u crypto-policies-scripts && \
    zypper -n clean --all

#
# Stage 2: Download and compile su-exec
#
FROM stage1 AS stage2

# Download and compile su-exec
RUN zypper -n install gcc && \
    curl -o /usr/local/bin/su-exec.c -SL "https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c" && \
    echo 44d84566f8685273335fc44a82348eb71a6759792c9f0947f7a8be45dbac4d5685e7e6b59cdaf19bd13932f08bb383d9bd4aa37ff56ffac733695e55b5d76391 \
        /usr/local/bin/su-exec.c | sha512sum -c - && \
    gcc -Wall /usr/local/bin/su-exec.c -o /usr/local/bin/su-exec && \
    chmod +x /usr/local/bin/su-exec && \
    rm /usr/local/bin/su-exec.c

#
# Stage 3: The remainder of the actual image definition
#
FROM stage1

# Copy su-exec
COPY --from=stage2 /usr/local/bin/su-exec /usr/local/bin/su-exec

# Add scripts to be executed during startup
COPY startup /startup
ADD https://raw.githubusercontent.com/CAFapi/caf-common/v1.19.0/container-cert-script/install-ca-cert.sh \
    /startup/startup.d/install-ca-cert-base.sh
RUN chmod +x /startup/* /startup/startup.d/*

# Create symlink to support the use of 'gosu' command
RUN ln -s /usr/local/bin/su-exec /usr/local/bin/gosu

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--", "/startup/startup.sh"]

# Add other useful scripts
COPY scripts /scripts
RUN chmod +x /scripts/*
