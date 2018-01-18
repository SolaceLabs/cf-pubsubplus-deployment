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

export SYSTEM_DOMAIN=${SYSTEM_DOMAIN:-"bosh-lite.com"}

export CF_DEPLOYMENT_VERSION=${CF_DEPLOYMENT_VERSION:-"v1.7.0"}

export STEMCELL_VERSION=${STEMCELL_VERSION:-"3468.17"}
export STEMCELL_NAME="bosh-stemcell-$STEMCELL_VERSION-warden-boshlite-ubuntu-trusty-go_agent.tgz"
export STEMCELL_URL="https://s3.amazonaws.com/bosh-core-stemcells/warden/$STEMCELL_NAME"

cd $WORKSPACE

if [ ! -d $WORKSPACE/cf-deployment ]; then
 git clone https://github.com/cloudfoundry/cf-deployment.git
fi

cd cf-deployment
git checkout $CF_DEPLOYMENT_VERSION

echo "Checking stemcell $STEMCELL_NAME"

  FOUND_STEMCELL=`bosh stemcells | grep bosh-warden-boshlite-ubuntu-trusty-go_agent | grep $STEMCELL_VERSION | wc -l`
  if [ "$FOUND_STEMCELL" -eq "0" ]; then
     bosh upload-stemcell $STEMCELL_URL
  else
     echo "$STEMCELL_NAME was found $FOUND_STEMCELL"
  fi

echo "Loading cloud-config bosh-lite-cloud-config.yml"
bosh update-cloud-config $SCRIPTPATH/bosh-lite-cloud-config.yml

bosh -d cf deploy cf-deployment.yml \
	-o operations/bosh-lite.yml \
	-o operations/use-compiled-releases.yml \
	--vars-store $WORKSPACE/deployment-vars.yml \
	-v system_domain=$SYSTEM_DOMAIN

