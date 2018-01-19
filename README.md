# CF-SOLACE-MESSAGING-DEPLOYMENT

A Cloud Foundry Solace Messaging BOSH Deployment

## Table of contents

[About](#about)

[Prerequisites](#prerequisites)

[Deployment](#deployment)

[Registering the Service Broker](#registering-broker)

<a name="about"></a>
## About

This project provides a BOSH 2 manifest for a Solace Messaging deployment.

This project takes advantage of new features such as:

- [cloud config](https://bosh.io/docs/cloud-config.html)
- [job links](https://bosh.io/docs/links.html)
- [new CLI](https://github.com/cloudfoundry/bosh-cli)
  - The new BOSH CLI must be installed according to the instructions [here](https://bosh.io/docs/cli-v2.html).

<a name="prerequisites"></a>
## Prerequisites

- A deployment of [BOSH](https://github.com/cloudfoundry/bosh)
- A deployment of [Cloud Foundry](https://github.com/cloudfoundry/cf-deployment), tested on v1.7.0
- Instructions for installing BOSH and Cloud Foundry can be found at http://docs.cloudfoundry.org/.
- A deployment of [Cloud Foundry MySQL](https://github.com/cloudfoundry/cf-mysql-deployment)
- Stemcell: ubuntu-trusty, tested on version: "3468.17"
- Compatible Solace BOSH releases: Version 1.4.0+
- Operator resolving BOSH cloud-config
   For correct resource allocation for each vm_type and plan please consult [Solace Pivotal Tile Installation Documentation](http://docs.pivotal.io/partners/solace-messaging/installing.html)

### The Solace BOSH Releases

These Solace provided BOSH Releases can be obtained from Solace, or extracted from a Solace Pivotal Tile.
- solace-vmr
- solace-messaging
- docker-bosh, version 30.1.4

Using the Solace Pivotal Tile you can extract the necessary BOSH releases that need to be used for this deployment.

* The Solace Pivotal Evaluation Tile is available for download from [PivNet](https://network.pivotal.io/products/solace-messaging/).
* The Solace Pivotal Enterprise Tile is available by contacting Solace.

Please download or obtain a Solace Pivotal Tile file and keep it around for later use. 

For example, download version 1.4.0 and place it in:

~~~~
cf-solace-messaging-deployment/workspace/solace-messaging-1.4.0.pivotal
~~~~

The Solace Pivotal Tile file is a zip file from which we can extract the required BOSH releases.

Use extract_tile.sh to extract the relevant contents we need.

~~~~
cd workspace
extract_tile.sh -t solace-messaging-1.4.0.pivotal
~~~~

The same can be done using 'unzip':

~~~~
cd workspace
unzip -o -d . solace-messaging-1.4.0.pivotal releases/*.tgz
~~~~

Example of uploading the Solace provided releases to BOSH.
~~~~
bosh upload-release workspace/releases/docker-30.1.4.tgz
bosh upload-release workspace/releases/solace-messaging-1.4.0.tgz
bosh upload-release workspace/releases/solace-vmr-1.4.0.tgz
~~~~

<a name="deployment"></a>
## Deployment

### Deployment manifest capabilities

The solace-deployment manifest expresses key but not all features of the underlying Solace BOSH releases.

Variable controls are provided for:

| Variable      | Optional | Description |
| --- | --- | --- |
| mysql_plan               | No | MySQL database plan selection. Please consider an HA service for a production deployment. |
| starting_port            | No | The VMR will listen on a range of ports starting from this port number. |
| vmr_admin_password       | No | The 'admin' password for the VMR.  Will set property admin_password |
| shared_plan_instances    | Yes | The number of VMR instances to create supporting the "shared" plan |
| large_plan_instances     | Yes | The number of VMR instances to create supporting the "large" plan |
| medium_ha_plan_instances | Yes | The number of VMR instances to create supporting the "medium-ha" plan |
| large_ha_plan_instances  | Yes | The number of VMR instances to create supporting the "large-ha" plan |
| community_plan_instances | Yes | The number of VMR instances to create supporting the "community" plan. This will have no effect when using an enterprise solace-vmr release. |

Just keep in mind that any __*plan_instances__ are static, and setting them all Zero means there is no inventory to support the solace-messaging plans.

The manifest contains many properties which are not variable controlled, but may be adjusted if necessary.

| Property      | Optional | Description |
| --- | --- | --- |
| admin_user          | No | The username of the admin user.  Must be 'admin' in the current version. |
| semp_port           | No | The Port the VMR will use to listen for SEMP requests (administrative operations) |
| semp_ssl_port       | No | The Secure Port the VMR will use to listen for SEMP requests (administrative operations) |
| ssh_port            | No | The Port the VMR will listen onto for direct ssh access to the VMR's CLI |
| vmr_agent_port      | No | The Port the VMR-Agent will listen onto for instructions from service broker |
| syslog_config       | Yes | Syslog configuration |
| tcp_routes_config   | Yes | TCP Routes configuration |
| ldap_config         | Yes | LDAP Configuration |

BOSH operator files provide controls for:

| File      | Description |
| --- | --- |
| [bosh_lite.yml](operations/bosh_lite.yml)              | Downscaling and adjusting key settings to work on bosh-lite |
| [disable_service_broker_open_security_group.yml](operations/disable_service_broker_open_security_group.yml)  | Disable service broker's open access security group ( required to access MySQL service and manage VMRs ) |
| [enable_global_access_to_plans.yml](operations/enable_global_access_to_plans.yml) | Enables global access to solace-messaging service during service broker installation. |
| [is_enterprise.yml](operations/is_enterprise.yml) | Adjusts the manifest to reflect enterprise VMR settings. Can only be used with an enterprise edition of solace-vmr bosh release containing an enterprise VMR |
| [is_evaluation.yml](operations/is_evaluation.yml) | Adjusts the manifest to reflect evaluation VMR settings. Can only be used with an evaluation edition of solace-vmr bosh release containing an evaluation VMR, which can be downloaded [here](https://network.pivotal.io/products/solace-messaging/). |
| [use_java_builpack_offline.yml](operations/use_java_builpack_offline.yml) | Using java_builpack_offline for the service broker |
| [google_cloud.yml](operations/google_cloud.yml) | Adjusts manifest vm_types for a google cloud deployment |
| [config_tls.yml](operations/config_tls.yml) | TLS Configuration. See the example [var file](operations/example-vars-files/certs.yml)   |


Only one of these files can be used, [is_evaluation.yml](operations/is_evaluation.yml) or [is_enterprise.yml](operations/is_enterprise.yml). Please select the one matching your available solace-vmr bosh release.

Sample iaas-support:
- [bosh-lite](iaas-support/bosh-lite/)
- [Openstack](iaas-support/openstack/)
- [GCP](operations/google_cloud.yml)

### Deployment manifest limitations:

While the capabililties of the Solace BOSH releases are well documented in [Solace Pivotal Tile Documentation](http://docs.pivotal.io/partners/solace-messaging/),
not all Solace BOSH release capabilities have been fully expressed in this deployment project with samples.
Futures releases of this deployment project will address these capabilities:

- No TLS Config
- No Syslog Config
- No LDAP Config
- No TCP Routes Config

### How to deploy

Assuming the operator has resolved all [prerequisites](#prerequisites), just use the bosh cli to deploy.
This is a sample of a deployment of an evaluation edition of Solace Message on bosh-lite, the deployment is named 'solace_messaging', it depends on 'cf' deployment.

~~~~
bosh -d solace_messaging \
	deploy solace-deployment.yml \
	-o operations/set_plan_inventory.yml \
	-o operations/bosh_lite.yml \
	-o operations/is_evaluation.yml \
	-o operations/enable_global_access_to_plans.yml \
	--vars-store $WORKSPACE/deployment-vars.yml \
	-v system_domain=bosh-lite.com  \
	-v app_domain=bosh-lite.com  \
	-v cf_deployment=cf  \
	-l vars.yml \
	-l release-vars.yml 
~~~~

<a name="registering-broker"></a>
## Registering the Service Broker

Registering the Service Broker is required to access solace-messaging as a service in Cloud Foundry. 

Please use the provided errand 'deploy-all' to install the service broker and add 'solace-messaging' to the marketplace.

~~~~
bosh -d solace_messaging run-errand deploy-all
~~~~

## Developement and testing

The [dev](./dev) folder contains supporting tools that can help do some testing on bosh-lite.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Release Notes and Versioning

This project uses [SemVer](http://semver.org/) for versioning. For the versions available and corresponding release notes, see the [Releases in this repository](https://github.com/SolaceLabs/cf-solace-messaging-deployment/releases).

## Authors

See the list of [contributors](https://github.com/SolaceLabs/cf-solace-messaging-deployment/contributors) who participated in this project.

## License

This project is licensed under the Apache License, Version 2.0. - See the [LICENSE](LICENSE) file for details.

## Resources

For more information about Bosh, Cloud Foundry and the Solace Messaging service these resources:
- [Solace Messaging for Pivotal Cloud Foundry](http://docs.pivotal.io/solace-messaging/)
- [Solace Messaging tutorials and sample application for Cloud Foundry](http://dev.solace.com/get-started/pcf-tutorials/)
- [Cloud Foundry Documentation](http://docs.cloudfoundry.org/)
- [Bosh Documentation](http://bosh.io/docs)
- For an introduction to Cloud Foundry: https://www.cloudfoundry.org/
- For an introduction to Bosh : http://mariash.github.io/learn-bosh/

For more information about Solace technology in general please visit these resources:

- The Solace Developer Portal website at: http://dev.solacesystems.com
- Understanding [Solace technology.](http://dev.solacesystems.com/tech/)
- Ask the [Solace community](http://dev.solacesystems.com/community/).
