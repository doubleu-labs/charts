# Valkey

This chart deploys a Valkey instance. 

## Installing

```sh
helm install dns oci://ghcr.io/doubleu-labs/charts/valkey
```

## Architectures

The following configurations are available by defining `architecture`:

- `standalone` - A single-server instance
- `replica` - A single master with `N` replicas
  - `replica.sentinel.enabled=true` - Deploys Sentinels to monitor the primary
  instances
- `cluster` - A group of `N` sharded primaries and `X` replicas for each primary

### Standalone

This is the default deployment architecture. A single primary server is created.

### Replica

This architecture deploys a single primary and `N` read-only replicas.

```yaml
# values.yaml
architecture: replica
replica:
  replicas: 3
```

#### Sentinel

> [!WARNING]
> This is not a completely tested configuration. Use at your own risk. 

Enabling Sentinel will deploy `N` Sentinel services that will monitor the
primary and promote a replica if it becomes unreachable.

```yaml
# values.yaml
architecture: replica
replica:
  replicas: 3
  sentinel:
    enabled: true
    count: 3
    quorum: 2
```

### Cluster

> [!CAUTION]
> TLS does not currently work with a clustered deployment. ***Do not use!***

> [!IMPORTANT]
> Due to Valkey internal limitations and how cluster nodes are informed of each
> other, in Cluster mode the Release Name is restricted to 12 characters when
> deploying 9 or fewer nodes, and 10 characters when deploying more than 9
> nodes. Use the `fullnameOverride` value to set an alternative name if the
> Release Name does not meet these requirements.
>
> This chart "abuses" hostname resolution to avoid complex reconfiguration upon
> cluster startup that would populate the Cluster IP addresses of nodes.
> Hostnames are provided in place of IP addresses, but Valkey truncates these
> values to 46 characters (the POSIX value for `INET6_ADDRSTRLEN`). Therefore,
> for Cluster DNS resolution to function, the value of
> `<RELEASE_NAME>-cluster-X.<RELEASE_NAME>-headless.<NAMESPACE>.svc` ***MUST*** 
> be less than 46 total characters.

This architecture deploys `N` number of sharded primary nodes and `X` number of
replicas per primary. I.e. `3` primaries and `1` replica will deploy `6` total
nodes.

```yaml
architecture: cluster
cluster:
  init: true
  primary:
    count: 3
  replica:
    count: 1
```

## Authentication

By default, authentication is disabled. If enabled, the `default` user will be
disabled and the user `admin` will be created. The credentials for the `admin`
user will be located in a `kubernetes.io/basic-auth` typed `Secret` named 
`<RELEASE>-user-admin`.

The `admin` username can be changed by setting the `auth.adminName` value.

```yaml
# values.yaml
auth:
  enabled: true
  adminName: ""
```

## TLS

By default, TLS is disabled. Existing certificates or CertManager can be used.

To use an existing certificate, set the name of the secret next to the name of
the `architecture` used:

```yaml
# values.yaml
tls:
  existingSecret:
    primary: ""
    replica: ""
    cluster: ""
    sentinel: ""
```

To leverage CertManager, enabled it and provide the `Issuer`/`ClusterIssuer`
details:

```yaml
# values.yaml
tls:
  certManager:
    enabled: true
    issuer:
      name: my-issuer
```

To use the CSI driver, enable that:

```yaml
# values.yaml
tls:
  certManager:
    enabled: true
    csiDriver: true
    issuer:
      name: my-issuer
```
