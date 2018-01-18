#!/bin/bash

# Cross-OS compatibility ( greadlink, gsed )
[[ `uname` == 'Darwin' ]] && {
	which greadlink gsed > /dev/null || {
		echo 'ERROR: GNU utils required for Mac. You may use homebrew to install them: brew install coreutils gnu-sed'
		exit 1
	}

   shopt -s expand_aliases
   alias readlink=`which greadlink`
   alias sed=`which gsed`
}

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
WORKSPACE=${WORKSPACE:-$SCRIPTPATH/../workspace}

source $SCRIPTPATH/cf_env.sh

## Just making sure there is a 'java_buildpack_offline' as it is a current requirement for the service broker manifest.

# This is NOT an offline version, but it will do for testing...
cf create-buildpack java_buildpack_offline https://github.com/cloudfoundry/java-buildpack/releases/download/v4.7.1/java-buildpack-v4.7.1.zip 0

