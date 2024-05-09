# Charts

This repository contains Helm Charts used in DoubleU Labs.

To add this repository:

```sh
helm repo add doubleu-labs https://labs.doubleu.codes/charts
```

## dns

```sh
helm --namespace=dns install dns doubleu-labs/dns
```
