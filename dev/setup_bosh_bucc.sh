#!/bin/bash

export SCRIPT="$( basename "${BASH_SOURCE[0]}" )"
export SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export WORKSPACE=${WORKSPACE:-$SCRIPTPATH/../workspace}

export BOSH_NON_INTERACTIVE=${BOSH_NON_INTERACTIVE:-true}

if [ ! -d $WORKSPACE ]; then
  mkdir -p $WORKSPACE
fi

cd $WORKSPACE

if [ ! -d bucc ]; then
 git clone https://github.com/starkandwayne/bucc.git
fi

sed -i 's/vm_memory: 4096/vm_memory: 8192/' $WORKSPACE/bucc/ops/cpis/virtualbox/vars.tmpl

$WORKSPACE/bucc/bin/bucc up --cpi virtualbox --lite --debug | tee $WORKSPACE/bucc_up.log
$WORKSPACE/bucc/bin/bucc env > $WORKSPACE/bosh_env.sh


