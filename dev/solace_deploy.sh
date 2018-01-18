#!/bin/bash

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
WORKSPACE=${WORKSPACE:-$SCRIPTPATH/../workspace}

cd $SCRIPTPATH/..

# bosh -d solace_messaging run-errand delete-all

#	-o operations/set_vmr_version.yml  \

bosh -d solace_messaging \
	deploy solace-deployment.yml \
	-o operations/plan_inventory.yml \
	-o operations/bosh_lite.yml \
	--vars-store $WORKSPACE/deployment-vars.yml \
	-v system_domain=bosh-lite.com  \
	-v cf_deployment=cf  \
	-v vmr_edition=evaluation \
	-l vars.yml \
	-l local-vars.yml

bosh -d solace_messaging run-errand deploy-all

