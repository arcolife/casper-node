#!/bin/bash

set -e

# export USER_ID=$(id -u)
# export GROUP_ID=$(id -g)
# envsubst < /passwd.template > /tmp/passwd
# export LD_PRELOAD=/usr/lib64/libnss_wrapper.so
# export NSS_WRAPPER_PASSWD=/tmp/passwd
# export NSS_WRAPPER_GROUP=/etc/group
#
# echo $(id)

RUST_BACKTRACE=full RUST_LOG=debug \
	      casperlabs-node validator \
	      -c=/root/casperlabs-node/resources/local/config.toml
	      -C=validator_net.root_addr=$ROOT_ADDR \
	      -C=validator_net.bind_interface=$BIND_INTERFACE \
	      -C=validator_net.bind_port=$BIND_PORT

exec "$@"
