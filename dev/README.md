# DEV

Development and testing support tools.

## Table of contents

[About](#About)

[Requirements](#Requirements)

[Deployment](#Deployment)

This folder contains some basic scripts to support a deployment of solace messaging to on bosh-lite.
This can be used for development and testing.

<a name="Requirements"></a>
## Requirements

In order to use solace-messaging these requirements need to be met:

* Install Virtualbox
* Install BOSH Cli v2
* Install BOSH Director 
* Install Cloud Foundry 
* Install CF Cli
* Install MySQL for Cloud Foundry

<a name="install_bosh"></a>
### Install BOSH

A BOSH Deployment is required with sufficient RAM and Disk to support the desired installation.

A quick way to get started with BOSH is to use [BUCC](https://github.com/starkandwayne/bucc).

This script will use BUCC on a Linux or Mac , there is NO support for Windows yet. 
~~~~
setup_bosh_bucc.sh
~~~~

This will use 8GB of RAM for a VM, install BOSH and create workspace/bosh_env.sh
This is enough to install all the tools and deploy a single solace VMR for testing.

Verify bosh is deployed, we expect to see no listed VMs, and no errors accessing BOSH.
~~~~
source ../workspace/bosh_env.sh
bosh vms
~~~~

Ensure routes are setup.
~~~~
source ../workspace/bosh_env.sh
../workspace/bucc/bin/bucc routes
~~~~

<a name="install_cf"></a>
### Install Cloud Foundry

How to deploy cloud foundry to BOSH. 
This requires access to BOSH, this should be already done from the previous step.

~~~~
cf_deploy.sh
~~~~

Cloud Foundry (CF) Is now installed, verify access to CF. Expect no errors.

~~~~
cf_env.sh
cf orgs
cf target -o system
cf create-space system
cf target -o system
cf m
~~~~

<a name="install_cf_mysql"></a>
### Install MySQL for Cloud Foundry

How to deploy MySQL for cloud foundry to BOSH. 

~~~~
cf_env.sh
cf_mysql_deploy.sh
~~~~

Verify MySQL is installed, and its plans are visible in Cloud Foundry

~~~~
cf target -o test
cf m
~~~~

<a name="Deployment"></a>
## Deployment

With the installation of BOSH, Cloud Foundry and MySQL for Cloud Foundry we are now ready to add Solace Messaging.

<a name="deploy_extract"></a>
### Obtain and extract the BOSH releases of a Solace Pivotal Tile.

~~~
extract_tile.sh -t solace-messaging-1.4.0-POC1.pivotal
~~~

This will unzip the file and keep the required BOSH releases under workspace/releases/*.tgz

<a name="deploy_upload"></a>
### Upload the BOSH releases 

This will uploaded the releases found in workspace/releases/*.tgz to BOSH
~~~~
solace_upload_releases.sh
~~~~

<a name="deploy_solace_messaging"></a>
### Deploy Solace Messaging 

Adjust the [vars.yml](../vars.yml)  to set the number of VMRs, set shared_plan_instances to 1.
By default an evaluation VMR is assumed to be in use. 

If you are using the enterprise edition:
~~~~
export VMR_EDITION="enterprise"
~~~~

This will deploy Solace Messaging to BOSH and adds Solace Messaging as a Service to Cloud Foundry

~~~~
solace_deploy.sh
~~~~

Verify solace-messaging is available

~~~~
cf target -o test
cf m
~~~~

You expect no errors, and you should see solace-messaging with its plans visible in the marketplace.


### Creating and using solace-messaging services

So you have a deployment, you can go ahead and try out [Solace Messaging tutorials and sample application for Cloud Foundry](http://dev.solace.com/get-started/pcf-tutorials/)

## Other notes.

There are current limitations with the bosh-virtualbox and the deployment cannot be simply resumed if virtual box was shutdown.
If you want to keep your deployment on virtual box, remeber to pause and save it before any reboot/shutdown.


