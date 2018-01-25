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

if [ -f $SCRIPTPATH/cf_env.sh ]; then
 $SCRIPTPATH/cf_env.sh
fi

cd $WORKSPACE

if [ -f bosh_env.sh ]; then
 source bosh_env.sh
fi

if [ ! -d cf-mysql-deployment ]; then
  git clone https://github.com/cloudfoundry/cf-mysql-deployment.git
fi

cd cf-mysql-deployment

bosh \
  -d cf-mysql \
  deploy cf-mysql-deployment.yml \
  -o operations/bosh-lite.yml \
  -o $SCRIPTPATH/cf_mysql_add-broker.yml \
  -o operations/register-proxy-route.yml \
  -o operations/latest-versions.yml \
  -l $SCRIPTPATH/cf_mysql_vars.yml \
  --vars-store $WORKSPACE/deployment-vars.yml

[[ $? -eq 0 ]] && {
  bosh -d cf-mysql run-errand broker-registrar-vm
}

[[ $? -eq 0  ]] && {
 echo "Create a test org and space to check marketplace"
 cf create-org test
 cf target -o test
 cf create-space test
 cf target -o test
 cf m -s p-mysql
}
