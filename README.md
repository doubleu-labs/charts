# Charts

This repository contains Helm Charts used in DoubleU Labs.

To add this repository:

```sh
helm repo add doubleu-labs https://labs.doubleu.codes/charts
```

## dns

[`README`](./charts/dns/README.md)

```sh
helm --namespace=dns install dns doubleu-labs/dns
```
