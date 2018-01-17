
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
WORKSPACE=${WORKSPACE:-$SCRIPTPATH/../workspace}

export BOSH_NON_INTERACTIVE=${BOSH_NON_INTERACTIVE:-true}

export SYSTEM_DOMAIN=${SYSTEM_DOMAIN:-"bosh-lite.com"}

cd $WORKSPACE

if [ ! -d $WORKSPACE/cf-deployment ]; then
 git clone https://github.com/cloudfoundry/cf-deployment.git
fi

cd cf-deployment

bosh upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent 

bosh update-cloud-config $SCRIPTPATH/bosh-lite-cloud-config.yml

bosh -d cf deploy cf-deployment.yml \
	-o operations/bosh-lite.yml \
	-o operations/use-compiled-releases.yml \
	--vars-store $WORKSPACE/deployment-vars.yml \
	-v system_domain=$SYSTEM_DOMAIN

