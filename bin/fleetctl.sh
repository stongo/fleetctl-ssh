#!/bin/bash
# modified from https://github.com/deis/deis/blob/master/controller/scheduler/fleetctl.
set -e

OPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"
[[ $FLEETW_KEY ]] && OPTIONS="-i $FLEETW_KEY $OPTIONS"

# set debug if provided as an envvar
[[ $DEBUG ]] && set -x

# if fleet unit is defined, scp it to the remote host
if [[ $FLEETW_UNIT && ($FLEETW_UNIT_DATA || $FLEETW_UNIT_FILE) ]]; then
  if [[ $FLEETW_UNIT_DATA ]]; then
    unitfile=$(mktemp /tmp/fleetrc.XXXX)
    echo $FLEETW_UNIT_DATA | base64 -d > $unitfile
  else
    unitfile=$FLEETW_UNIT_FILE
  fi
  SCP_OPTIONS=$OPTIONS
  [[ $FLEETW_PORT ]] && SCP_OPTIONS="-P $FLEETW_PORT $SCP_OPTIONS"
  scp $SCP_OPTIONS $unitfile core@$FLEETW_HOST:$FLEETW_UNIT
fi

# run the fleetctl command remotely
SSH_OPTIONS="-A $OPTIONS"
[[ $FLEETW_PORT ]] && SSH_OPTIONS="-p $FLEETW_PORT $SSH_OPTIONS"
ssh $SSH_OPTIONS core@$FLEETW_HOST fleetctl $@
