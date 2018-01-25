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

export BOSH_NON_INTERACTIVE=${BOSH_NON_INTERACTIVE:-true}
export VMR_EDITION=${VMR_EDITION:-"evaluation"}

if [ -f $WORKSPACE/bosh_env.sh ]; then
 source $WORKSPACE/bosh_env.sh
fi

cd $SCRIPTPATH/..

bosh -d solace_messaging \
	deploy solace-deployment.yml \
	-o operations/set_plan_inventory.yml \
	-o operations/bosh_lite.yml \
	-o operations/is_${VMR_EDITION}.yml \
	-o operations/config_tls.yml \
	-o operations/enable_global_access_to_plans.yml \
	--vars-store $WORKSPACE/deployment-vars.yml \
	-v system_domain=bosh-lite.com  \
	-v app_domain=bosh-lite.com  \
	-v cf_deployment=cf  \
	-l vars.yml \
	-l release-vars.yml \
        -l operations/example-vars-files/certs.yml 


[[ $? -eq 0 ]] && { 
  $SCRIPTPATH/solace_add_service_broker.sh 
}

