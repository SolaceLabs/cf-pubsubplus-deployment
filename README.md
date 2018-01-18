# CF-SOLACE-MESSAGING-DEPLOYMENT

A Cloud Foundry Solace Messaging BOSH Deployment

## Table of contents

[Prequisites](#prequisites)

[Deployment](#deployment)

[Registering the Service Broker](#registering-broker)

This project provides a BOSH 2 manifest for a Solace Messaging deployment.

This project takes advantage of new features such as:

- [cloud config](https://bosh.io/docs/cloud-config.html)
- [job links](https://bosh.io/docs/links.html)
- [new CLI](https://github.com/cloudfoundry/bosh-cli)
  - The new BOSH CLI must be installed according to the instructions [here](https://bosh.io/docs/cli-v2.html).

<a name="usage"></a>
## Prerequisites

- A deployment of [BOSH](https://github.com/cloudfoundry/bosh)
- A deployment of [Cloud Foundry](https://github.com/cloudfoundry/cf-release), [final release 193](https://github.com/cloudfoundry/cf-release/tree/v193) or greater
- Instructions for installing BOSH and Cloud Foundry can be found at http://docs.cloudfoundry.org/.
- A deployment of [Cloud Foundry MySQL](https://github.com/cloudfoundry/cf-mysql-deployment)
- Java Offline BuildPacks 
- Stemcell
- Solace BOSH releases

### The Solace BOSH Releases

These Solace provided BOSH Releases can be obtained from Solace, or extracted from a Solace Pivotal Tile.
- solace-vmr
- solace-messaging
- docker-bosh

Using the Solace Pivotal Tile you can extract the necessary BOSH releases that need to be used for this deployment.

* The Solace Pivotal Evaluation Tile is available for download from [PivNet](https://network.pivotal.io/products/solace-messaging/).
* The Solace Pivotal Enterprise Tile is available by contacting Solace.
* [Solace Pivotal Tile Documentation](http://docs.pivotal.io/partners/solace-messaging/)

Please download the Solace Pivotal Tile and keep it around for later use. 

For my example I have downloaded version 1.4.0 and placed it in:

~~~~
cf-solace-messaging-deployment/workspace/solace-messaging-1.4.0.pivotal
~~~~

The Solace Pivotal Tile file is a zip file from which we can extract the required bosh releases.

Use extract_tile.sh to extract the relevant contents we need.

~~~~
cd workspace
extract_tile.sh -t solace-messaging-1.4.0-POC1.pivotal
~~~~

The same can be done using 'unzip'

~~~~
cd workspace
unzip -o -d .  solace-messaging-1.4.0-POC1.pivotal releases/*.tgz
~~~~


Example of uploading the Solace provided releases to BOSH.
~~~~
bosh upload-release workspace/releases/docker-30.1.4.tgz
bosh upload-release workspace/releases/solace-messaging-1.4.0-POC1.tgz
bosh upload-release workspace/releases/solace-vmr-1.4.0-POC1.tgz
~~~~

