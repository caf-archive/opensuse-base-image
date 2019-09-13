#!/bin/bash
#
# Copyright 2017-2018 Micro Focus or one of its affiliates.
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
processId = $BASHPID;
log() {
    echo "[$(date +%H:%M:%S.%3NZ) #$(printf '%03X\n' $processId).??? INFO -            -   ] ${0##*/}: $@"
}

# Run the executable scripts that are in the drop-in folder
log "Running startup scripts..."
for script in $(dirname "$0")/startup.d/*; do
    if [ -x "$script" ]; then
        log "Running ${script##*/}..."
        "$script" |& sed -ure "s/^warning:/WARN:/I; /^(info|error|warn|debug|trace):/I!s/^/info: /; s/^([^:]*): ?(.*)$/[$(date +%H:%M:%S.%3NZ) #$(printf '%03X\n' $BASHPID).??? \U\1\E -            -   ] ${script##*/}: \2/"
    fi
done

log "Startup scripts completed"

# Execute the specified command
exec "$@"
