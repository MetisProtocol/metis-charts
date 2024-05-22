# Setup Sequencer Node

## Generate Sequencer Key for themis

```sh
docker run --rm -it -v ./tmp:/var/lib/themis metisdao/themis init
```

You will get the key in following files

```
tmp
├── config
│   ├── app.toml
│   ├── config.toml
│   ├── genesis.json
│   ├── node_key.json
│   ├── priv_validator_key.json
│   └── themis-config.toml
└── data
    └── priv_validator_state.json

3 directories, 7 files
```

you need to backup `node_key.json` and `priv_validator_key.json` and ensure their security

## Submit your Sequencer information

1. Run following commands to get the public key and address of your sequencer

```sh
$ docker run --rm -it -v ./tmp:/var/lib/themis metisdao/themis show-account
{
    "address": "0xBF578472333179247657a6023D7418D6Dc792Ef3",
    "pub_key": "0x042e1a3735f93ddbad4f697dc576e37b159f31f344808bff2a18269b228fc83663cfb66da6462fd258b5ef09d4a532a41ef96d0d589f1e0401317c21534c0239ad"
}
$ docker run --rm -it -v ./tmp:/var/lib/themis metisdao/themis show-privatekey
{
    "priv_key": "0x...REDACTED..."
}
```

NOTE: the `priv_key` is the same with `SEQ_PRIV` env in the l2geth service.

2. Fork https://github.com/MetisProtocol/metis-sequencer-resources

3. Refer to its README to add your sequencer info

4. Make a pull request

## Prepare config for your node

1. Edit `tmp/config/config.toml` and update `persistent_peers` field.

Please note, the peer info is not public in this repo for now, you can only get it after you're whitelisted.

2. Copy the genesis file

```sh
cp docs/networks/<NETWORK_NAME>/themis/genesis.json tmp/config
cp docs/networks/<NETWORK_NAME>/themis/themis-config.toml tmp/config
```

you wil need to create a configmap for the the `tmp/config`

```
tmp/config
├── app.toml
├── config.toml
├── genesis.json
├── node_key.json
├── priv_validator_key.json
└── themis-config.toml

1 directory, 6 files
```

refer to the [Create and Copy themis config](../charts/metis-node/README.md) section

## Create an EKS cluster

you can use your own way to do that, the terraform module can guide you what system requirements you should use.
