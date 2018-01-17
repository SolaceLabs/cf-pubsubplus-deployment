#!/bin/bash

bosh interpolate solace-deployment.yml \
	-o operations/plan_inventory.yml \
	-o operations/bosh-lite.yml \
	-v system_domain=bosh-lite.com  \
	-v cf_deployment=cf  \
	-v vmr_edition=evaluation \
	-l vars.yml \
	-l local-vars.yml


