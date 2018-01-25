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

if [ -f $WORKSPACE/bosh_env.sh ]; then
 source $WORKSPACE/bosh_env.sh
fi

cd $SCRIPTPATH/..

DEPLOYMENT_FOUND_COUNT=`bosh deployments | grep solace_messaging | wc -l`
SOLACE_VMR_RELEASE_FOUND_COUNT=`bosh releases | grep solace-vmr | wc -l`
SOLACE_MESSAGING_RELEASE_FOUND_COUNT=`bosh releases | grep solace-messaging | wc -l`

if [ "$DEPLOYMENT_FOUND_COUNT" -eq "1" ]; then

 bosh -d solace_messaging run-errand delete-all

 bosh -d solace_messaging delete-deployment

fi

 if [ "$SOLACE_VMR_RELEASE_FOUND_COUNT" -eq "1" ]; then
    # solace-vmr
    echo "Deleting release solace-vmr"
    bosh -n delete-release solace-vmr
 else
    echo "No solace-vmr release found"
 fi

 if [ "$SOLACE_MESSAGING_RELEASE_FOUND_COUNT" -eq "1" ]; then
    # solace-messaging
    echo "Deleting release solace-messaging"
    bosh -n delete-release solace-messaging
 else
    echo "No solace-messaging release found"
 fi


ORPHANED_DISKS=$( bosh disks --orphaned --json | jq '.Tables[].Rows[] | select(.deployment="solace_messaging") | .disk_cid' | sed 's/\"//g' )

for DISK_ID in $ORPHANED_DISKS; do
        echo "Will delete $DISK_ID"
        bosh -n delete-disk $DISK_ID
        echo
        echo "Orphaned Disk $DISK_ID was deleted"
        echo
done

