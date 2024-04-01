# Setup Sequencer Node

## Generate Sequencer Key for themis

```sh
docker run --rm -it -v ./tmp:/var/lib/themis metisdao/themis init
```

You will get the key in following files, and you need to backup them and ensure their security

```
tmp/config/node_key.json
tmp/config/priv_validator_key.json
```

## Submit your Sequencer information

https://github.com/MetisProtocol/metis-sequencer-resources

Run following commands to get the public key and address of your sequencer

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

## Edit Themis config

Edit `tmp/config/config.toml` and update `persistent_peers` field.

Please note, the peer info is not public in this repo for now, you can only get it after you're whitelisted.
