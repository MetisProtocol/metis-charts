#!/bin/sh

set -ex

mkdir -p /var/lib/themis/data

if [ ! -f /var/lib/themis/data/priv_validator_state.json ]; then
    echo '{"height": "0","round": "0","step": 0}' > /var/lib/themis/data/priv_validator_state.json
fi

mkdir -p /var/lib/themis/config

if [ ! -f /var/lib/themis/config/node_key.json ]; then
    cp /keys/node_key.json /var/lib/themis/config/
fi

if [ ! -f /var/lib/themis/config/priv_validator_key.json ]; then
    cp /keys/priv_validator_key.json /var/lib/themis/config/
fi

if [ ! -f /var/lib/themis/config/genesis.json ]; then
    cp /config/genesis.json /var/lib/themis/config/
fi

cp /config/themis-config.toml /var/lib/themis/config/
cp /config/config.toml /var/lib/themis/config/
