# CF-SOLACE-MESSAGING-DEPLOYMENT

A Cloud Foundry Solace PubSub+ BOSH Deployment

## Table of contents

[About](#about)

[Prerequisites](#prerequisites)

[Deployment](#deployment)

[Registering the Service Broker](#registering-broker)

<a name="about"></a>
## About

This project provides a BOSH 2 manifest for a Solace PubSub+ deployment.

This project takes advantage of new features such as:

- [cloud config](https://bosh.io/docs/cloud-config.html)
- [job links](https://bosh.io/docs/links.html)
- [new CLI](https://github.com/cloudfoundry/bosh-cli)
  - The new BOSH CLI must be installed according to the instructions [here](https://bosh.io/docs/cli-v2.html).

<a name="prerequisites"></a>
## Prerequisites

- A deployment of [BOSH](https://github.com/cloudfoundry/bosh)
- A deployment of [Cloud Foundry](https://github.com/cloudfoundry/cf-deployment), tested on v3.0.0
- Instructions for installing BOSH and Cloud Foundry can be found at https://docs.cloudfoundry.org/.
- Stemcell: ubuntu-xenial, tested on version: "97.32"
- Compatible Solace PubSub BOSH releases: Version 2.2.x
- Operator resolving BOSH cloud-config

   For correct resource allocation for each vm_type and plan please consult [Solace Pivotal Tile Installation Documentation](https://docs.pivotal.io/partners/solace-pubsub/installing.html)


### The Solace BOSH Releases

These Solace provided BOSH Releases can be obtained from Solace, or extracted from a Solace Pivotal Tile.
- solace-pubsub
- solace-pubsub-broker
- solace-service-adapter
- docker-33.0.0
- cf-mysql-36.16.0
- on-demand-service-broker-0.24.0.

Using the Solace Pivotal Tile you can extract the necessary BOSH releases that need to be used for this deployment.

* The Solace Pivotal Evaluation Tile is available for download from [PivNet](https://network.pivotal.io/products/solace-pubsub/).
* The Solace Pivotal Enterprise Tile is available by contacting Solace.

Please download or obtain a Solace Pivotal Tile file and keep it around for later use. 

For example, download version 2.2.1 and place it in:

~~~~
cf-solace-messaging-deployment/workspace/solace-pubsub-2.2.1.pivotal
~~~~

The Solace Pivotal Tile file is a zip file from which we can extract the required BOSH releases.

~~~~
cd workspace
unzip -o -d . solace-pubsub-2.2.1.pivotal releases/*.tgz
~~~~

Example of uploading the Solace provided releases to BOSH.
~~~~
bosh upload-release workspace/releases/cf-mysql-36.16.0.tgz
bosh upload-release workspace/releases/docker-33.0.0.tgz
bosh upload-release workspace/releases/on-demand-service-broker-0.24.0.tgz
bosh upload-release workspace/releases/solace-pubsub-broker-2.2.1.tgz
bosh upload-release workspace/releases/solace-pubsub-2.2.1.tgz
bosh upload-release workspace/releases/solace-service-adapter-2.2.1.tgz
~~~~

For deployment on bosh-lite, docker bosh release version 31.0.1 must be used.

~~~~
curl -sL -o docker-31.0.1.tgz "https://bosh.io/d/github.com/cf-platform-eng/docker-boshrelease?v=31.0.1"
bosh upload-release docker-31.0.1.tgz
~~~~

<a name="deployment"></a>
## Deployment

### Deployment manifest capabilities

The solace-deployment manifest expresses key but not all features of the underlying Solace BOSH releases.

Variable controls are provided for:

| Variable      | Optional | Description |
| --- | --- | --- |
| starting_port            | No | Solace message broker will listen on a range of ports starting from this port number. |
| vmr_admin_password       | No | The 'admin' password for the Solace message broker.  Will set property admin_password |
| secure_service_credentials | No | Increases security by hiding service instance credentials from VCAP serviecs |
| solace_broker_cf_organization | No | The CF organization to deploy the Solace PubSub+ service broker |
| solace_broker_cf_space | No | The CF space inside of solace_broker_cf_organization to deploy the Solace PubSub+ service broker |
| solace_router_client_id | No | The id for the solace_router uaa client
| solace_router_client_secret | No | The secret for the solace_router uaa client |
| solace_vmr_cert          | Yes | The certificate to be used on the message brokers for secure connections. Use with [set_solace_vmr_cert.yml](operations/set_solace_vmr_cert.yml), [example](operations/example-vars-files/certs.yml). Can be combined with [disable_service_broker_certificate_validation.yml](operations/disable_service_broker_certificate_validation.yml) if this is a test certificate.  |
| mysql_for_pcf_service_name               | No | The name of the MySQL service registered with CF. Applied when using MySQL for PCF. Please consider an HA service for a production deployment. See operations files below for selecting a MySQL deployment |
| mysql_for_pcf_service_plan               | No | The size of the internal MySQL databas, i.e. 100mb. Applied when using MySQL for PCF. |
| mysql_external_hostname | Yes | A hostname for MySQL. Applied when using an external MySQL. See operations files below for selecting a MySQL deployment |
| mysql_external_port | Yes | The port for MySQL. Applied when using an external MySQL |
| mysql_external_dbname | Yes | The database name for MySQL. Applied when using an external MySQL |
| mysql_external_user | Yes | The username for MySQL. Applied when using an external MySQL |
| mysql_external_password | Yes | The password for MySQL. Applied when using an external MySQL |
| shared_plan_instances    | Yes | The number of Solace Pubsub message broker instances to create supporting the "enterprise-shared" plan |
| large_plan_instances     | Yes | The number of Solace Pubsub message broker instances to create supporting the "enterprise-large" plan |
| medium_ha_plan_instances | Yes | The number of Solace Pubsub message broker instances to create supporting the "enterprise-medium-ha" plan |
| large_ha_plan_instances  | Yes | The number of Solace Pubsub message broker instances to create supporting the "enterprise-large-ha" plan |
| standard_medium_plan_instances    | Yes | The number of Solace Pubsub message broker instances to create supporting the "standard-medium" plan |
| standard_medium_ha_plan_instances | Yes | The number of Solace Pubsub message broker instances to create supporting the "standard-medium-ha" plan |

Just keep in mind that any __*plan_instances__ are static, and setting them all Zero means there is no inventory to support the solace-pubsub plans.

The manifest contains many properties which are not variable controlled, but may be adjusted if necessary.

| Property      | Optional | Description |
| --- | --- | --- |
| admin_user          | No | The username of the admin user.  Must be 'admin' in the current version. |
| semp_port           | No | The Port the message broker will use to listen for SEMP requests (administrative operations) |
| semp_ssl_port       | No | The Secure Port the message broker will use to listen for SEMP requests (administrative operations) |
| ssh_port            | No | The Port the message broker will listen onto for direct ssh access to the message broker's CLI |
| vmr_agent_port      | No | The Port the broker-agent will listen onto for instructions from service broker |
| syslog_config       | Yes | Syslog configuration |
| tcp_routes_config   | Yes | TCP Routes configuration |
| ldap_config         | Yes | LDAP Configuration |

BOSH operator files provide controls for:

| File      | Description |
| --- | --- |
| [bosh_lite.yml](operations/bosh_lite.yml)              | Downscaling and adjusting key settings to work on bosh-lite |
| [disable_service_broker_open_security_group.yml](operations/disable_service_broker_open_security_group.yml)  | Disable service brokers open access security group ( required to access MySQL service and manage message brokers ) |
| [enable_global_access_to_plans.yml](operations/enable_global_access_to_plans.yml) | Enables global access to the solace-pubsub service offering during service broker installation. |
| [use_java_builpack_offline.yml](operations/use_java_builpack_offline.yml) | Using java_builpack_offline for the service broker |
| [google_cloud.yml](operations/google_cloud.yml) | Adjusts manifest vm_types for a google cloud deployment |
| [set_solace_vmr_cert.yml](operations/set_solace_vmr_cert.yml) | Adds a server certificate to the solace_vmr_cert TLS Configuration. See the example [var file](operations/example-vars-files/certs.yml). If no solace_vmr_cert is provided as a property, a self signed certificate will be generate by bosh. |
| [add_vmr_trusted_certs.yml](operations/add_vmr_trusted_certs.yml) | Adds trusted root certificates to the trusted_root_certificates TLS Configuration. See the example [var file](operations/example-vars-files/certs.yml). There can be several certificates assigned to the solace_trusted_root_cert.certificate property, as shown in that example.
| [disable_service_broker_certificate_validation.yml](operations/disable_service_broker_certificate_validation.yml) | Disables certificate validation on the service broker when it communicates with the message brokers. This should only be considered for non production test certificates. |
| [is_enterprise.yml](operations/is_enterprise.yml) | Adjusts the manifest to reflect enterprise Solace Pubsub message broker settings. Can only be used with an enterprise edition of solace-pubsub bosh release containing an enterprise version of Solace PubSub+ |
| [is_evaluation.yml](operations/is_evaluation.yml) | Adjusts the manifest to reflect evaluation Solace Pubsub message broker settings. Can only be used with an evaluation edition of solace-pubsub bosh release containing an evaluation version of Solace PubSub+, which can be downloaded [here](https://network.pivotal.io/products/solace-pubsub/). |
| [enable_tcp_routes.yml](operations/enable_tcp_routes.yml) | Adds tcp route configuration, see [tcp_routes_config.yml](operations/example-vars-files/tcp_routes_config.yml) file. 
| [enable_ldap.yml](operations/enable_ldap.yml) | Adds ldap configuration, see this [vars.yml](operations/example-vars-files/ldap_config.yml) file. 
| [set_management_access_ldap.yml](operations/set_management_access_ldap.yml) | Adds ldap authorization for management access. Configuration is found in the same ldap [vars.yml](operations/example-vars-files/ldap_config.yml) file.
| [set_application_access_ldap.yml](operations/set_application_access_ldap.yml) | Adds ldap authorization for application access. 
| [enable_syslog.yml](operations/enable_syslog.yml) | Addes syslog configuration, see [syslog_config.yml](operations/example-vars-files/syslog_config.yml) file. 
| [internal_mysql_ha.yml](operations/internal_mysql_ha.yml) | Enables high availability for the internal mysql provided by Solace Pubsub |
| [external_mysql.yml](operations/external_mysql.yml) | Disables the internal mysql provided by Solace Pubsub and instead targets an external mysql |
| [mysql_for_pcf.yml](operations/mysql_for_pcf.yml) | Disables the internal mysql provided by Solace Pubsub in favour of Mysql for PCF |
| [orphaned_resource_policy_delete.yml](operations/orphaned_resource_policy_delete.yml) | Sets the default orphaned resource policy for all plans to 'Delete' away from default of 'Abort' |
| [orphaned_resource-policy_service_owned.yml](operations/orphaned_resource_policy_service_owned.yml) | Sets the default orphaned resource policy for all plans to 'Service Owned' away from default of 'Abort' |

Only one of these required files can be used and should only be applied as the last operator file, [is_evaluation.yml](operations/is_evaluation.yml) or [is_enterprise.yml](operations/is_enterprise.yml). Please select the one matching your available solace-pubsub bosh release.

Sample iaas-support:
- [bosh-lite](iaas-support/bosh-lite/)
- [Openstack](iaas-support/openstack/)
- [GCP](operations/google_cloud.yml)


### How to deploy

Assuming the operator has resolved all [prerequisites](#prerequisites), just use the bosh cli to deploy.

This is a sample of a deployment of an evaluation edition of Solace Message on bosh-lite with self-signed bosh generated message broker certificates, the deployment is named 'solace_pubsub', it depends on 'cf' deployment.

~~~~

bosh -d solace_pubsub \
        deploy solace-deployment.yml \
        -o operations/set_plan_inventory.yml \
        -o operations/bosh_lite.yml \
        -o operations/set_solace_vmr_cert.yml \
        -o operations/disable_service_broker_certificate_validation.yml \
        -o operations/enable_global_access_to_plans.yml \
        -o operations/is_evaluation.yml \
        --vars-store $WORKSPACE/deployment-vars.yml \
        -v system_domain=bosh-lite.com  \
        -v app_domain=bosh-lite.com  \
        -v cf_deployment=cf  \
        -l vars.yml \
        -l release-vars.yml \
        -v docker_version=31.0.1

~~~~

<a name="registering-broker"></a>
## Registering the Service Broker

Registering the Service Broker is required to access solace-pubsub as a service in Cloud Foundry. 

Please use the provided errand 'deploy-all' to install the service broker and add 'solace-pubsub' to the marketplace.

~~~~
bosh -d solace_pubsub run-errand deploy-all
~~~~

## Developement and testing

See the [solace-messaging-cf-dev](https://github.com/SolaceLabs/solace-messaging-cf-dev) projects which supports a local deployment of Solace PubSub+ for Cloud Foundry.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Release Notes and Versioning

This project uses [SemVer](https://semver.org/) for versioning. For the versions available and corresponding release notes, see the [Releases in this repository](https://github.com/SolaceLabs/cf-solace-messaging-deployment/releases).

## Authors

See the list of [contributors](https://github.com/SolaceLabs/cf-solace-messaging-deployment/contributors) who participated in this project.

## License

This project is licensed under the Apache License, Version 2.0. - See the [LICENSE](LICENSE) file for details.

## Resources

For more information about Bosh, Cloud Foundry and the Solace Messaging service these resources:
- [Solace PubSub+ for Pivotal Cloud Foundry](https://docs.pivotal.io/partners/solace-pubsub/)
- [Solace PubSub+ tutorials and sample application for Cloud Foundry](https://dev.solace.com/samples/solace-samples-cloudfoundry-java/)
- [Cloud Foundry Documentation](https://docs.cloudfoundry.org/)
- [Bosh Documentation](https://bosh.io/docs)
- For an introduction to Cloud Foundry: https://www.cloudfoundry.org/
- For an introduction to Bosh : https://mariash.github.io/learn-bosh/

For more information about Solace technology in general please visit these resources:

- The Solace Developer Portal website at: https://dev.solace.com
- Understanding [Solace technology.](https://dev.solace.com/tech/)
- Ask the [Solace community](https://dev.solace.com/community/).
