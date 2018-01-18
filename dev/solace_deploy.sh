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

cd $SCRIPTPATH/..

# bosh -d solace_messaging run-errand delete-all

bosh -d solace_messaging \
	deploy solace-deployment.yml \
	-o operations/plan_inventory.yml \
	-o operations/bosh_lite.yml \
	--vars-store $WORKSPACE/deployment-vars.yml \
	-v system_domain=bosh-lite.com  \
	-v app_domain=bosh-lite.com  \
	-v cf_deployment=cf  \
	-v vmr_edition=evaluation \
	-l vars.yml \
	-l release-vars.yml

bosh -d solace_messaging run-errand deploy-all

