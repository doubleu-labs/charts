# Lazy CA

This chart is built on top of [`cert-manager`](https://cert-manager.io/).

This is a simple helper to generate an isolated certificate authoritity for use
with cluster-internal encrypted communications, mTLS client authentication in
mind specifically.

A self-signed CA and corrosponding `Issuer` are created.

## Installing

```sh
helm install database-ca oci://ghcr.io/doubleu-labs/charts/lazyca
```

## Usage

The `Issuer` is the same as the release name, unless `issuer.nameOverride` value
is set.

Place this value in the `.spec.issuerRef.name` field of your `Certificate` or
`CertificateRequest`:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: database-client
spec:
  secretName: database-client-certificate
  usages:
  - client auth
  commonName: client
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: database-ca
    kind: Issuer
    group: cert-manager.io
```

CA certificates use an ECDSA 384 `privateKey` by default, though any
`privateKey` configuration supported by `cert-manager` is also supported.
