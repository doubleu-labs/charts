# DNS

This chart differs from the official CoreDNS chart in that `values.yaml`
supports specifying `snippets` and configuring DoH/DoT certificates through
`cert-manager`.

The default container `ghcr.io/doubleu-labs/coredns` contains the following
external plugins:

- `filter`: [github.com/wranders/coredns-filter](https://github.com/wranders/coredns-filter)
- `netboxdns`: [github.com/doubleu-labs/coredns-netbox-plugin-dns](https://github.com/doubleu-labs/coredns-netbox-plugin-dns)

## Installing

```sh
helm repo add doubleu-labs https://labs.doubleu.codes/charts

helm --namespace=dns install dns doubleu-labs/dns
```

## Configure

Here is an example `values.yaml` that utilizes external plugins and DoH/DoT:

```yaml
snippets:
- name: base
  plugins:
  - name: health
  - name: ready
  - name: errors
  - name: debug
  - name: filter
    configBlock: |-
      listresolver tls://9.9.9.9 dns.quad9.net
      block list wildcard https://big.oisd.nl
  - name: netboxdns
    configBlock: |-
      token someNetboxToken
      url https://10.0.0.20/
      tls /etc/coredns/tls/ca.crt
      fallthrough
  - name: forward
    parameters: . tls://9.9.9.9 tls://149.112.112.112
    configBlock: |-
      tls_servername dns.quad9.net
      health_check 5s
  - name: cache
    parameters: 30s

servers:
- plugins:
  - name: import
    parameters: base
- zones:
  - scheme: https://
  - scheme: tls://
  plugins:
  - name: tls
    parameters: /etc/coredns/tls/tls.crt /etc/coredns/tls/tls.key /etc/coredns/tls/ca.crt
  - name: import
    parameters: base

certificate:
  certManager:
    enabled: true
    commonName: dns.example.com
    subjectAltNames:
      dns:
      - dns.example.com
      ipAddress:
      - 10.0.0.10
      - 10.0.0.11
    issuer:
      name: selfsigned-ca-issuer
      kind: ClusterIssuer

service:
  type: LoadBalancer
```
