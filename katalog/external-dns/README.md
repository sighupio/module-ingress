# ExternalDNS

<!-- <SD-DOCS> -->

## Overview

ExternalDNS synchronizes exposed Kubernetes Services and Ingresses with DNS providers. In the Ingress Module it is deployed in two flavors, one for "private" records and one for "public" records, and it relies on cloud resources (for example an IAM role and Route53 zones on AWS) that the distribution provisions automatically through the accompanying Terraform modules.

## Upstream project

This package is based on the upstream [ExternalDNS][external-dns-github].

## Deployment

This package is deployed and managed internally as part of **Ingress Module** when you create a cluster with `furyctl`. It is not meant to be configured directly: it has no dedicated options in the `furyctl.yaml` schema, and its DNS providers and credentials (for example the AWS IAM role and Route53 zones) are derived from your cluster configuration and provisioned automatically by the distribution. See the [module documentation](../../README.md) to learn how the Ingress Module is installed.

<!-- Links -->

[external-dns-github]: https://github.com/kubernetes-sigs/external-dns

<!-- </SD-DOCS> -->

## License

For license details please see [LICENSE](../../LICENSE)
