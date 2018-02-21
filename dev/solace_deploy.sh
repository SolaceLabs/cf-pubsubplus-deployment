#! /bin/bash

export SCRIPT="$( basename "${BASH_SOURCE[0]}" )"
export SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export WORKSPACE=${WORKSPACE:-$SCRIPTPATH/../workspace}

export VARS_PATH=$SCRIPTPATH/../vars.yml
export TLS_PATH=$SCRIPTPATH/../operations/example-vars-files/certs.yml

export BOSH_NON_INTERACTIVE=${BOSH_NON_INTERACTIVE:-true}
export VMR_EDITION=${VMR_EDITION:-"evaluation"}

if [ -f $WORKSPACE/bosh_env.sh ]; then
 source $WORKSPACE/bosh_env.sh
fi

function showUsage() {
    echo
    echo "Usage: $CMD_NAME [OPTIONS]"
    echo
    echo "OPTIONS"
    echo "  -s <starting_port>        provide starting port "
    echo "  -p <vmr_admin_password>   provide vmr admin password "
    echo "  -h                        show command options "
    echo "  -v <vars.yml file path>   provide vars.yml file path "
    echo "  -l <tls_config.yml file>  provide tls config file path"
    echo "  -e                        is enterprise mode"
    echo "$WORKSPACE"
}


while getopts "l:s:p:v:eh" arg; do
    case "${arg}" in
        l) 
            export TLS_PATH="$OPTARG"
            shift
            ;;
        s)
            starting_port="$OPTARG"
            cd ..
            grep -q 'starting_port' vars.yml && sed -i "s/starting_port.*/starting_port: $starting_port/" vars.yml || echo "starting_port: $starting_port" >> vars.yml
	    ;;
        p)
            vmr_admin_password="${OPTARG}"
            grep -q 'vmr_admin_password' vars.yml && sed -i "s/vmr_admin_password.*/vmr_admin_password: $vmr_admin_password/" vars.yml || echo "vmr_admin_password: $vmr_admin_password" >> vars.yml
            ;;
        v)
            export VARS_PATH="$SCRIPTPATH/$OPTARG"
            shift
            echo $SCRIPTPATH
            ;; 
        e) 
	    export VMR_EDITION="enterprise"
            ;;
        h)
            showUsage
            exit 0
       ;;
       \?)
       >&2 echo
       >&2 echo "Invalid option: -$OPTARG" >&2
       >&2 echo
       showUsage
       exit 1
       ;;
    esac
done
#shift $((OPTIND-1))


cd $SCRIPTPATH/..

SOLACE_VMR_RELEASE_FOUND_COUNT=`bosh releases | grep solace-vmr | wc -l`

if [ "$SOLACE_VMR_RELEASE_FOUND_COUNT" -eq "0" ]; then
   echo "solace-vmr release seem to be missing from bosh, please upload-release to bosh"
   exit 1
fi

SOLACE_MESSAGING_RELEASE_FOUND_COUNT=`bosh releases | grep solace-messaging | wc -l`

if [ "$SOLACE_MESSAGING_RELEASE_FOUND_COUNT" -eq "0" ]; then
   echo "solace-messaging release seem to be missing from bosh, please upload-release to bosh"
   exit 1
fi

bosh -d solace_messaging \
	deploy solace-deployment.yml \
	-o operations/set_plan_inventory.yml \
	-o operations/bosh_lite.yml \
	-o operations/set_solace_vmr_cert.yml \
	-o operations/enable_global_access_to_plans.yml \
	-o operations/is_${VMR_EDITION}.yml \
	--vars-store $SCRIPTPATH/deployment-vars.yml \
	-v system_domain=bosh-lite.com  \
	-v app_domain=bosh-lite.com  \
	-v cf_deployment=cf  \
	-l $VARS_PATH \
	-l release-vars.yml \
        -l $TLS_PATH

[[ $? -eq 0 ]] && { 
  $SCRIPTPATH/solace_add_service_broker.sh 
}

