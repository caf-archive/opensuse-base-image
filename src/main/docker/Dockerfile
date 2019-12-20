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

FROM opensuse/leap:latest

# Set the locale manually to a set inherited from the base image (defaults to POSIX)
ENV LANG=en_US.utf8

# Update the OS packages, install cURL and postgreSQL client
RUN zypper -n refresh && \
    zypper al permissions && \
    zypper -n update && \
    zypper -n install curl postgresql

# Add scripts to be executed during startup
COPY startup /startup
ADD https://raw.githubusercontent.com/CAFapi/caf-common/v1.14.0/container-cert-script/install-ca-cert.sh \
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

# Tag the image
ARG BUILD_NUMBER
ARG BUILD_DATE
ARG GIT_REPO
ARG GIT_BRANCH
ARG GIT_COMMIT

LABEL Build.Number="$BUILD_NUMBER" \
      Build.Date="$BUILD_DATE" \
      Git.Repo="$GIT_REPO" \
      Git.Branch="$GIT_BRANCH" \
      Git.Commit="$GIT_COMMIT"
