#!/bin/bash
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

# Create a convenience function for logging
log() {
    echo "[$(date +%F\ %H:%M:%S.%3NZ) #$(printf '%03X\n' $$).??? INFO  -            -   ] ${0##*/}: $@" 1>&2
}

# Export file based secrets
if [ "$USE_FILE_BASED_SECRETS" = true ]; then
    log "Running export-file-based-secrets.sh..."
    source $(dirname "$0")/../scripts/export-file-based-secrets.sh
    export_file_based_secrets_status=${PIPESTATUS[0]}
    if [ $export_file_based_secrets_status -ne 0 ]; then
        echo "ERROR: Error running export-file-based-secrets.sh" |& $(dirname "$0")/../scripts/caf-log-format.sh "startup.sh"
        exit $export_file_based_secrets_status
    fi
fi

# Run the executable scripts that are in the drop-in folder
log "Running startup scripts..."
for script in $(dirname "$0")/startup.d/*; do
    if [ -x "$script" ]; then
        log "Running ${script##*/}..."
        "$script" |& $(dirname "$0")/../scripts/caf-log-format.sh "${script##*/}" 1>&2
        status=${PIPESTATUS[0]}
        if [ $status -ne 0 ]; then
            log "Error running ${script##*/}"
            exit $status
        fi
    fi
done

log "Startup scripts completed"

# If the RUNAS_USER environment variable is set, execute the specified command as that user.
if [ -n "$RUNAS_USER" ]; then
    log "The RUNAS_USER environment variable has been set with a user named ${RUNAS_USER}. \
Subsequent commands will be run as this user. \
Please note that this user is expected to already exist, and will not be created."
    exec /usr/local/bin/su-exec $RUNAS_USER "$@"
else
    log "The RUNAS_USER environment variable is not set, subsequent commands will be run as the default user."
    exec "$@"
fi
