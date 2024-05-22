# Metis node

The pods use host network to enable p2p connections, which means you should have dedicated instances for them.

## System Requirements

for AWS:

- c5.2xlarge
- ebs gp3 with 200 MB/s throughput, 500Gi

## Port Configuration

Please ensure these ports are exposed for P2P connection.

| Port  | Description           | Protocol | Source    |
| ----- | --------------------- | -------- | --------- |
| 30303 | L2geth P2P Port (UDP) | UDP      | 0.0.0.0/0 |
| 30303 | L2geth P2P Port (TCP) | TCP      | 0.0.0.0/0 |
| 26656 | Themis Node P2P Port  | TCP      | 0.0.0.0/0 |

Refer to https://github.com/ericlee42/metis-sequencer-terraform-module for the details

## Examples for Sequencers

1. Associate EIPs with l2geth and themis node

It's required to sequencer nodes

```yaml
scripts:
  eip:
    create: true

serviceAccount:
  create: true
  name: "eip-setup"
  automount: true
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::1234567890:role/eip-associate-role-name

l2geth:
  attachServiceAccount: true
  initContainers:
    - name: aws
      image: public.ecr.aws/aws-cli/aws-cli:latest
      command: ["/tools/eip.sh", "YOUR EIP ADDRESS"]
      volumeMounts:
          - name: eip
            mountPath: /tools
  volumes:
    - name: eip
      configMap:
      name: NAME-PREFIX-eip-setup
      defaultMode: 0775

themis:
  attachServiceAccount: true
  initContainers:
    - name: aws
      image: public.ecr.aws/aws-cli/aws-cli:latest
      command: ["/tools/eip.sh", "YOUR EIP ADDRESS"]
      volumeMounts:
          - name: eip
          mountPath: /tools
  volumes:
    - name: eip
      configMap:
      name: NAME-PREFIX-eip-setup
      defaultMode: 0775
```

2. Affinity and toleration

I assume you have two instace, one for l2geth and l1dtl, another for themis and its bridge

```
# l2geth
labels = {
   "node.meisdevops.link" = "l2geth",
}

taints {
    key    = "node.meisdevops.link"
    value  = "l2geth"
    effect = "NO_SCHEDULE"
}

# themis
labels = {
   "node.meisdevops.link" = "themis",
}

taints {
    key    = "node.meisdevops.link"
    value  = "themis"
    effect = "NO_SCHEDULE"
}
```

So we will have following configuration in values.yaml

```yaml
l2geth:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: "node.metis.io"
                operator: In
                values: ["l2geth"]
  tolerations:
    - key: "node.metis.io"
      value: "l2geth"

# deploy the l1dtl with l2geth on the same instance due to l2geth depends on l1dtl
l1dtl:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: "node.metis.io"
                operator: In
                values: ["l2geth"]
  tolerations:
    - key: "node.metis.io"
      value: "l2geth"

# deploy the themis on a different instance with l2geth
themis:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: "node.metis.io"
                operator: In
                values: ["themis"]
  tolerations:
    - key: "node.metis.io"
      value: "themis"
```

3. Set sequencer private key

you can use Vault and Secret Manager to set the key

for example, you can use [secret manager csi](https://secrets-store-csi-driver.sigs.k8s.io/topics/set-as-env-var) to add it

```yaml
l2geth:
  envs:
    - name: SEQ_PRIV
      valueFrom:
        secretKeyRef:
          name: foosecret
          key: username
```

4. Create and Copy themis config

It's not recommended to use configmap and subpath to mapping the config file, you can use init container to copy the config files to the volume.

The initial file tree looks like:

```
├── config
│   ├── app.toml
│   ├── config.toml
│   ├── genesis.json
│   ├── node_key.json
│   ├── priv_validator_key.json
│   └── themis-config.toml
└── data
    └── priv_validator_state.json
```

you can get the `genesis.json` and `themis-config.toml` in `docs/networks/<network>/themis`

refer to the [sequencer.md](../../docs/sequencer.md) to generate the `node_key.json` and `priv_validator_key.json`

```yaml
scripts:
  initThemis: true

consensus:
  themis:
    initContainers:
      - name: init
        image: alpine
        command: ["/script/init.sh"]
        volumeMounts:
          - name: chaindata
            mountPath: /var/lib/themis
          - name: keys
            mountPath: /keys
          - name: config
            mountPath: /config
          - name: init
            mountPath: /script
  volumes:
    - name: chaindata
      persistentVolumeClaim:
        claimName: themis
    # create the secret externally
    - name: keys
      secret:
        name: themis-keys
        defaultMode: 0600
    # create the configmap externally
    - name: config
      configMap:
        name: themis-config
        defaultMode: 0664
    # the init shell
    - name: init
      configMap:
        name: NAME-PREFIX-init-themis-setup
        defaultMode: 0775
```
