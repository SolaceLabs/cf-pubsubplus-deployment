#!/bin/bash

export SCRIPT="$( basename "${BASH_SOURCE[0]}" )"
export SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export WORKSPACE=${WORKSPACE:-$SCRIPTPATH/../workspace}

cf api https://api.bosh-lite.com --skip-ssl-validation
export CF_ADMIN_PASSWORD=$(bosh int $WORKSPACE/deployment-vars.yml --path /cf_admin_password)  
cf auth admin $CF_ADMIN_PASSWORD  
