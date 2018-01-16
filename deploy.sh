#!/bin/bash

# bosh -d solace_messaging run-errand delete-all

bosh -d solace_messaging \
	deploy solace-deployment.yml \
	-o operations/plan_inventory.yml \
	-o operations/set_vmr_version.yml  \
	--vars-store ~/deployment-vars.yml \
	-v system_domain=bosh-lite.com  \
	-v cf_deployment=cf  \
	-v vmr_edition=evaluation \
	-l vars.yml


 bosh -d solace_messaging run-errand deploy-all

