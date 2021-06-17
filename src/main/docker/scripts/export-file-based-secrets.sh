#!/bin/bash
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

# Create a convenience function for info logging.
info() {
    echo "[$(date +%H:%M:%S.%3NZ) #$(printf '%03X\n' $$).??? INFO  -            -   ] ${0##*/}: $@"
}

# Create a convenience function for error logging.
error() {
    echo "[$(date +%H:%M:%S.%3NZ) #$(printf '%03X\n' $$).??? ERROR  -            -   ] ${0##*/}: $@"
}

# Create a function for exporting file-based secrets.
#
# For example, for each environment variable ending in the _FILE suffix:
#
#     ABC_PASSWORD_FILE=/var/somefile.txt
#
# read the contents of /var/somefile.txt (for example 'mypassword'), and export an environment variable named ABC_PASSWORD set to:
#
#     ABC_PASSWORD=mypassword
export_file_based_secrets() {
    env | while IFS= read -r env_var; do
        env_var_name=${env_var%%=*}
        env_var_value=${env_var#*=}
        if  [[ ${env_var_name} == *_FILE ]] ;
        then
            local env_var_name_without_file_suffix=${env_var_name%_FILE}
            if [ "${!env_var_name:-}" ] && [ "${!env_var_name_without_file_suffix:-}" ]; then
                error "Both $env_var_name and $env_var_name_without_file_suffix are set (but are exclusive)"
                exit 1
            fi            
            info "Found environment variable ending with the _FILE suffix: $env_var_name=$env_var_value, attempting to read the contents \
of $env_var_value..."
            if [ -e "$env_var_value" ]; then
                local file_contents=$(<${env_var_value})
                info "Successfully read contents of ${env_var_value}, exporting environment variable \
$env_var_name_without_file_suffix using the contents of ${env_var_value} as the value..."
                if export "$env_var_name_without_file_suffix"="$file_contents" ; then
                    info "Successfully exported environment variable $env_var_name_without_file_suffix"
                    unset "$env_var_name"
                else
                    error "Failed to export environment variable $env_var_name_without_file_suffix"
                    exit 1
                fi
            else 
                error "Failed to export the environment variable $env_var_name_without_file_suffix, file $env_var_value does not exist"
                exit 1
            fi
        fi 
    done
}

export_file_based_secrets
