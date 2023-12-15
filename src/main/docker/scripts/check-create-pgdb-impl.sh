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

#
# This script is intended to facilitate database creation so that a later
# running process can safely assume the configured database exists.
# This is particularly useful inside containers, where the application embeds
# dropwizard to maintain the target database's schema.
#
# ----------Variable Section-----------#
#Dummy values (come from environment vars)
#DATABASE_NAME=
#DATABASE_HOST=
#DATABASE_PASSWORD=
#DATABASE_PORT=
#DATABASE_USERNAME=
#DATABASE_APPNAME=

tmpDir="/tmp"
scriptName=$(basename "$0")
baseName="${scriptName%.*}"
tmpErr=$tmpDir/$baseName"-stderr"

# Check that the environment variable prefix to use has been passed
if [ $# -ne 1 ]; then
  echo "ERROR: Incorrect number of arguments specified"
  echo "Usage: $scriptName environment_variable_prefix"
  exit 1
fi

ENV_PREFIX=$1

# Need to convert prefixed variables to known values:
varName="$ENV_PREFIX"DATABASE_NAME
database_name=$(echo ${!varName})

varName="$ENV_PREFIX"DATABASE_HOST
database_host=$(echo ${!varName})

varName="$ENV_PREFIX"DATABASE_PORT
database_port=$(echo ${!varName})

varName="$ENV_PREFIX"DATABASE_USERNAME
database_username=$(echo ${!varName})

varName="$ENV_PREFIX"DATABASE_PASSWORD
database_password=$(echo ${!varName})

varName="$ENV_PREFIX"DATABASE_APPNAME
database_appname=$(echo ${!varName})

# ----------Function Section-----------#
function check_psql {
  if [ $(type -p psql) ]; then
      _psql=$(type -p psql)
  else
      echo "WARN: Install psql (to the system path) before this script can be used."
      exit 1
  fi

  if [[ "$_psql" ]]; then
    version=$("$_psql" --version 2>&1 | awk '{print $3}')
    echo "INFO: psql $version found, OK to continue"
  fi
}

function check_variables {
  local -i missingVar=0

  if [ -z "$database_name" ] ; then
    echo "ERROR: Mandatory variable "$(echo $ENV_PREFIX"DATABASE_NAME")" not defined"
    missingVar+=1
  fi

  if [ -z "$database_host" ] ; then
    echo "ERROR: Mandatory variable "$(echo $ENV_PREFIX"DATABASE_HOST")" not defined"
    missingVar+=1
  fi

  if [ -z "$database_port" ] ; then
    echo "ERROR: Mandatory variable "$(echo $ENV_PREFIX"DATABASE_PORT")" not defined"
    missingVar+=1
  fi

  if [ -z "$database_username" ] ; then
    echo "ERROR: Mandatory variable "$(echo $ENV_PREFIX"DATABASE_USERNAME")" not defined"
    missingVar+=1
  fi

  if [ -z "$database_password" ] ; then
    echo "ERROR: Mandatory variable "$(echo $ENV_PREFIX"DATABASE_PASSWORD")" not defined"
    missingVar+=1
  fi

  if [ -z "$database_appname" ] ; then
    echo "ERROR: Mandatory variable "$(echo $ENV_PREFIX"DATABASE_APPNAME")" not defined"
    missingVar+=1
  fi

  if [ $missingVar -gt 0 ] ; then
    echo "ERROR: Not all required variables for database creation have been defined, exiting."
    exit 1
  fi
}

function check_db_exist {
  echo "INFO: Checking database existence..."

# Need to set password for run
# Sending psql errors to file, using quiet grep to search for valid result
 if  PGPASSWORD="$database_password" \
   PGAPPNAME="$database_appname" psql --username="$database_username" \
   --host="$database_host" \
   --port="$database_port" \
   --variable database_name="$database_name" \
   --tuples-only \
   2>$tmpErr <<EOF | grep -q 1
SELECT 1 FROM pg_database WHERE datname = :'database_name';
EOF
 then
   echo "INFO: Database [$database_name] already exists."
   exit 0
 else
   if [ -f "$tmpErr" ] && [ -s "$tmpErr" ] ; then
     echo "ERROR: Database connection error, exiting."
     cat "$tmpErr"
     exit 1
   else
     echo "INFO: Database [$database_name] does not exist, creating..."
     create_db
   fi
 fi
}

function create_db {
# Need to set password for run
# Sending psql errors to file, stderr to NULL
# postgres will auto-lowercase database names unless they are quoted
  if  PGPASSWORD="$database_password" \
   PGAPPNAME="$database_appname" psql --username="$database_username" \
   --host="$database_host" \
   --port="$database_port" \
   --variable database_name="$database_name" \
   >/dev/null 2>$tmpErr <<EOF
CREATE DATABASE :"database_name";
EOF
  then
    echo "INFO: Database [$database_name] created."
  else
     echo "ERROR: Database creation error, exiting."
     cat "$tmpErr"
     exit 1
  fi
}

# -------Main Execution Section--------#

check_variables
check_psql
check_db_exist
