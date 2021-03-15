#!/bin/bash
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

MESOS_SANDBOX=${SSL_CA_CRT_DIR:-$MESOS_SANDBOX}

copy_certs() {
    IFS=',' read -a caFiles <<< "$SSL_CA_CRT"

    for caFile in "${caFiles[@]}"
    do
        if ! [ -e $MESOS_SANDBOX/$caFile ]
        then
            echo "CA Certificate at '$MESOS_SANDBOX/$caFile' not found"
            echo "Aborting further system CA certificate load attempts."
            exit 1
        fi

        echo "Installing CA Certificate on $1"
        sudo cp -v $MESOS_SANDBOX/$caFile $2/$caFile.crt
    done
}

if [ -n "$MESOS_SANDBOX" ] && [ -n "$SSL_CA_CRT" ]
then
    copy_certs "openSUSE" /etc/pki/trust/anchors
    sudo update-ca-certificates
else
    echo "Not installing CA Certificate."
fi
