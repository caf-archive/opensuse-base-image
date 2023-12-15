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

# A function for logging in the caf logging format.
caf_log() {
    echo "$@" |& $(dirname "$0")/../scripts/caf-log-format.sh "export-file-based-secrets.sh" 1>&2
}

# A function for exporting file-based secrets.
#
# For example, for each environment variable ending in the _FILE suffix:
#
#     ABC_PASSWORD_FILE=/var/somefile.txt
#
# read the contents of /var/somefile.txt (for example 'mypassword'), and export an environment variable named ABC_PASSWORD set to:
#
#     ABC_PASSWORD=mypassword
export_file_based_secrets() {
    while IFS='=' read -r -d '' env_var_name env_var_value; do
        if  [[ ${env_var_name} == *_FILE ]] ;
        then
            local env_var_name_without_file_suffix=${env_var_name%_FILE}
            if [ "${!env_var_name:-}" ] && [ "${!env_var_name_without_file_suffix:-}" ]; then
                caf_log "ERROR: Both $env_var_name and $env_var_name_without_file_suffix are set (but are exclusive)"
                exit 1
            fi            
            caf_log "INFO: Reading ${env_var_name} (${env_var_value})..."
            if [ -e "$env_var_value" ]; then
                local file_contents=$(<${env_var_value})
                if export "$env_var_name_without_file_suffix"="$file_contents" ; then
                    caf_log "INFO: Successfully exported environment variable $env_var_name_without_file_suffix"
                    unset "$env_var_name"
                else
                    caf_log "ERROR: Failed to export environment variable $env_var_name_without_file_suffix"
                    exit 1
                fi
            else 
                caf_log "ERROR: Failed to export env variable $env_var_name_without_file_suffix, file $env_var_value does not exist"
                exit 1
            fi
        fi 
    done < <(env -0)
}
export_file_based_secrets
unset -f caf_log # Don't export the caf_log function when this script is sourced
