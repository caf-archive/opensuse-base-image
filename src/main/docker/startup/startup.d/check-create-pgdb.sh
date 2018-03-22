#!/bin/bash
#
# Copyright 2015-2017 EntIT Software LLC, a Micro Focus company.
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

#
# This script is intended to facilitate database creation so that a later
# running process can safely assume the configured database exists.
# This is particularly useful inside containers, where the application embeds
# dropwizard to maintain the target database's schema.
#
# ----------Variable Section-----------#
#Dummy values (come from environment vars)
#CAF_DATABASE=
#CAF_DATABASE_HOST=
#CAF_DATABASE_PASSWORD=
#CAF_DATABASE_PORT=
#CAF_DATABASE_USERNAME=
ENV_PREFIX="CAF_"

tmpDir="/tmp"
scriptName=$(basename "$0")
baseName="${scriptName%.*}"
tmpErr=$tmpDir/$baseName"-stderr"

# Should arrive from environment definition.
# All database related variables will begin with it
#if [ -z $ENV_PREFIX ] ; then
#  ENV_PREFIX="CAF_"
#fi

# Need to convert prefixed variables to known values:
varName="$ENV_PREFIX"DATABASE_NAME
database_name=$(echo ${!varName})

# Or like this:
#database=$(eval echo \$$(echo $env_prefix"_DATABASE"))

varName="$ENV_PREFIX"DATABASE_HOST
datasource_host=$(echo ${!varName})

varName="$ENV_PREFIX"DATABASE_PORT
datasource_port=$(echo ${!varName})

varName="$ENV_PREFIX"DATABASE_USERNAME
datasource_user=$(echo ${!varName})

varName="$ENV_PREFIX"DATABASE_PASSWORD
datasource_password=$(echo ${!varName})

# ----------Function Section-----------#
function check_psql {
  if [ $(type -p psql) ]; then
      _psql=$(type -p psql)
  else
      echo "Install psql (to the system path) before this script can be used."
      exit 1
  fi

  if [[ "$_psql" ]]; then
    version=$("$_psql" --version 2>&1 | awk '{print $3}')
    echo "psql $version found, OK to continue"
  fi
}

function check_variables {
  local -i missingVar=0

  if [ -z $database_name ] ; then
    echo "Missing "$(echo $ENV_PREFIX"DATABASE_NAME")
    missingVar+=1
  fi

  if [ -z $datasource_host ] ; then
    echo "Missing "$(echo $ENV_PREFIX"DATABASE_HOST")
    missingVar+=1
  fi

  if [ -z $datasource_port ] ; then
    echo "Missing "$(echo $ENV_PREFIX"DATABASE_PORT")
    missingVar+=1
  fi

  if [ -z $datasource_user ] ; then
    echo "Missing "$(echo $ENV_PREFIX"DATABASE_USERNAME")
    missingVar+=1
  fi

  if [ -z $datasource_password ] ; then
    echo "Missing "$(echo $ENV_PREFIX"DATABASE_PASSWORD")
    missingVar+=1
  fi

  if [ $missingVar -gt 0 ] ; then
    echo "Not all required variables defined, exiting."
    echo "HINT: If the ENV_PREFIX variable is provided, expected database parameters will be constructed with it."
    exit 1
  fi
}

function check_db_exist {
  echo "Checking database existence..."

# Need to set password for run
# Sending psql errors to file, using quiet grep to search for valid result
 if  PGPASSWORD="$datasource_password" \
   psql --username="$datasource_user" \
   --host="$datasource_host" \
   --port="$datasource_port" \
   --tuples-only \
   --command="SELECT 1 FROM pg_database WHERE datname = '$database_name'" \
   2>$tmpErr | grep -q 1 \
 ; then
   echo "Database [$database_name] exists."
   exit 0
 else
   if [ -f "$tmpErr" ] && [ -s "$tmpErr" ] ; then
     echo "Database connection error, exiting."
     cat "$tmpErr"
     exit 1
   else
     echo "Database [$database_name] does not exist, creating..."
     create_db
   fi
 fi
}

function create_db {
# Need to set password for run
# Sending psql errors to file, stdout to NULL
# postgres will auto-lowercase database names unless they are quoted
  if  PGPASSWORD="$datasource_password" \
   psql --username="$datasource_user" \
   --host="$datasource_host" \
   --port="$datasource_port" \
   --command="CREATE DATABASE \"$database_name\"" \
   >/dev/null 2>$tmpErr \
  ; then
    echo "Database [$database_name] created."
  else
     echo "Database creation error, exiting."
     cat "$tmpErr"
     exit 1
  fi
}

# -------Main Execution Section--------#

check_variables
check_psql
check_db_exist