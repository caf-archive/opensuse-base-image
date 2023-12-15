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

logger="$1";
logger_sed_escaped="${logger//\\/\\\\}";
logger_sed_escaped="${logger_sed_escaped//\//\\/}";
logger_sed_escaped="${logger_sed_escaped//&/\\&}";

process_id="$BASHPID";

if [ "$2" ];
then
    process_id="$2"
fi

exec sed -ure '
    s/^warning:/WARN:/I;
    /^(info|error|warn|debug|trace):/I!s/^/info: /;
    s/^(\w{0,4}):/\1 :/;
    s/^([^:]*): ?(.*)$/\1:'"${logger_sed_escaped}"': \2/;
    s/'"'"'/'"'"'"'"'"'"'"'"'/g;
    s/^([^:]*):(.*)$/\/bin\/echo "[$(date "+%F %H:%M:%S.%3NZ")"'"'"' #'"$(printf '%03X\n' $process_id)"'.??? \U\1\E -            -   ] \2'"'"'/;
    e';
