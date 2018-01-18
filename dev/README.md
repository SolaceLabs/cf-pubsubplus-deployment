

- Given access to a bosh director

1) Install Cloud Foundry Sized for bosh-lite

cf_deploy.sh

2) Access the CF installation

cf_env.sh

3) Install mysql with added mysql plans for bosh-lite

cf_mysql_deploy.sh

4) Prepare PCF ( Will be fixed once we make the selection of java build pack operator controlled )

solace_prepare_pcf.sh

--- Now a solace messaging deployment can be done ----

extract_tile.sh -f SOLACE_TILE_FILE

solace_upload_releases.sh

Resolve any version details in release-vars.yml to match the versions contained in SOLACE_TILE_FILE, documentation should guide that..

solace_deploy.sh

