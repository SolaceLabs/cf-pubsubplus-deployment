#!/bin/bash

export SCRIPT="$( basename "${BASH_SOURCE[0]}" )"
export SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export WORKSPACE=${WORKSPACE:-$SCRIPTPATH/../workspace}

source $SCRIPTPATH/cf_env.sh

## Just making sure there is a 'java_buildpack_offline' as it is a current requirement for the service broker manifest.

# This is NOT an offline version, but it will do for testing...
cf create-buildpack java_buildpack_offline https://github.com/cloudfoundry/java-buildpack/releases/download/v4.7.1/java-buildpack-v4.7.1.zip 0

