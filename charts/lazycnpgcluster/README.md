# Lazy CloudNativePG Cluster

This is a simple helper to generate a CloudNative-PG database cluster, built on
top of [CloudNative-PG](https://cloudnative-pg.io/) and
[cert-manager](https://cert-manager.io/).

## Installing

```sh
helm install database oci://ghcr.io/doubleu-labs/charts/lazycnpgcluster
```

## Usage

The `Cluster` name is the same as the release name, unless `nameOverride` value
is set.

Installing a release with no `values` will result in a database that can be
accessed by using credentials in the created secret `{{ .Release.Name}}-app`,
and the user and database will be named `app`. The password is randomly
generated.

```yaml
. .
data:
  dbname: "app"
  host: "database-rw"
  jdbc-uri: "jdbc:postgresql://database-rw.dev:5432/app?password=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ab&user=app"
  password: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ab"
  pgpass: "database-rw:5432:app:app:abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ab\n"
  port: "5432"
  uri: "postgresql://app:abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ab@database-rw.dev:5432/app"
  user: "app"
  username: "app"
```

Using Netbox as an example, the database can be configured:

```sh
helm install netbox-db oci://ghcr.io/doubleu-labs/charts/lazycnpgcluster \
--set "database.name=netbox" \
--set "database.owner=netbox" \
--set "database.initdb=true"
```

If you wish to use client certificate authentication, you'll need two separate
certificate authorities: one for servers and the other for clients. The CA
certificates will need to be stored in Secrets of `kind: kubernetes.io/tls`
PEM-encoded as key `ca.crt`. Self-signed Cert-Manager installations are perfect
for this. You will also need to specify issuers that use the provided secrets.

```sh
helm install netbox-db oci://ghcr.io/doubleu-labs/charts/lazycnpgcluster \
--set "database.name=netbox" \
--set "database.owner=netbox" \
--set "database.initdb=true" \
--set "tls.enabled=true" \
--set "tls.clientCA.secretName=db-client-ca-certificate" \
--set "tls.clientCA.issuer.name=db-client-ca" \
--set "tls.serverCA.secretName=db-server-ca-certificate" \
--set "tls.serverCA.issuer.Name=db-server-ca"
```

Unless `tls.generateOwnerCert` is `false`, a Secret containing the client
certificate will be generated for the owner with the following name structure:

```raw
{{ .Release.Name }}-{{ .Values.database.name }}-{{ .Values.database.owner }}-client-certificate
```

or with the example: `netbox-db-netbox-netbox-client-certificate`. Along with
this certificate, an entry is automatically added to the `pg_hba.conf` file
allowing certificate authentication.

If additional users are required, add lines to `.Values.database.authRecords` to
append to `pg_hba.conf`:

```sh
# database.authRecords[0]="type database user address auth-method"
--set 'database.authRecords[0]="hostssl netbox myuser all cert"'
```

The above will allow the user `myuser` to access the `netbox` database using a
certificate created using the specified client CA.

Keep in mind that using two separate CAs will require mounting both CA secrets
in your consuming pod:

```yaml
containers:
- name: netbox
. . .
  volumeMounts:
  - name: database-tls
    mountPath: /home/user/.postgresql
volumes:
- name: database-tls
  projected:
    sources:
    - secret:
      name: netbox-db-netbox-netbox-client-certificate
      items:
      - key: tls.crt
        path: postgresql.crt
      - key: tls.key
        path: postgresql.key
        mode: 0600
    - secret:
      name: db-server-ca-certificate
      items:
      - key: ca.crt
        path: root.crt
```
