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
    echo "  -t <tls_config.yml file>  provide tls config file path"
    echo "  -e                        is enterprise mode"
    echo "  -a <syslog_config.yml>    provide syslog config file path"
    echo "  -r <tcp_config.yml>       provide tcp routes config file path" 
    echo "  -l <ldap_config.yml>      provide ldap config file path"   
    echo "  -b                        enable ldap management authorization access" 
    echo "  -c                        enable ldap application authorization access" 
}


while getopts "t:a:b:c:s:l:p:v:eh" arg; do
    case "${arg}" in
        b) 
             mldap=true
             ;;
        c) 
             aldap=true
             ;;
        t) 
            export TLS_PATH="$OPTARG"
            shift
            ;;
        a)
            export SYSLOG_PATH="$OPTARG"
            ;;
        r) 
	    export TCP_PATH="$OPTARG" 
            ;;
        l) 
	    export LDAP_PATH="$OPTARG"
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
            export VARS_PATH="$OPTARG"
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

if [ -f "$SYSLOG_PATH" ]; then
   sys='-o operations/enable_syslog.yml' 
   sysconf="-l $SYSLOG_PATH" 
fi

if [ -f "$LDAP_PATH" ]; then 
   ldap='-o operations/enable_ldap.yml' 
   ldapconf="-l $LDAP_PATH"
fi 

if [ -f "$mldap" ]; then 
   m='-o operations/set_management_access_ldap.yml'
fi 

if [ -f "$aldap" ]; then
   a='-o operations/set_application_access_ldap.yml' 
fi 

if [ -f "$TCP_PATH" ]; then
    tcp='-o operations/enable_tcp_routes.yml' 
    tcpconf="-l $TCP_PATH"
fi

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
        $ldap \
        $sys \
        $m \
        $a \
        $tcp \
        -o operations/enable_tcp_routes.yml \
	--vars-store $SCRIPTPATH/deployment-vars.yml \
	-v system_domain=bosh-lite.com  \
	-v app_domain=bosh-lite.com  \
	-v cf_deployment=cf  \
	-l $VARS_PATH \
	-l release-vars.yml \
        $tcpconf \
        $sysconf \
        $ldapconf \
        -l $TLS_PATH 
       

[[ $? -eq 0 ]] && { 
  $SCRIPTPATH/solace_add_service_broker.sh 
}

