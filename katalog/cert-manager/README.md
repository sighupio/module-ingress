# cert-manager

<!-- <SD-DOCS> -->

## Overview

cert-manager is a Kubernetes add-on that automates the management and issuance of TLS certificates from various issuing sources. It ensures certificates are valid and attempts to renew them before they expire. In the Ingress Module it is configured to use [Let's Encrypt][lets-encrypt] as the Certificate Authority, with `ClusterIssuer` as the default issuer kind.

## Upstream project

This package is based on the upstream [cert-manager][cert-manager-github].

## Deployment

This package is deployed as part of **Ingress Module** when you create a cluster with `furyctl`.

You can customize it under `spec.distribution.modules.ingress.certManager` in your `furyctl.yaml`. See the [module documentation](../../README.md) and the configuration reference ([EKSCluster][schema-reference-eks], [KFDDistribution][schema-reference-kfd], [OnPremises][schema-reference-onprem]) for the available options.

<!-- Links -->

[cert-manager-github]: https://github.com/cert-manager/cert-manager
[lets-encrypt]: https://letsencrypt.org/
[schema-reference-eks]: https://docs.sighup.io/docs/reference/ekscluster#specdistributionmodulesingress
[schema-reference-kfd]: https://docs.sighup.io/docs/reference/kfddistribution#specdistributionmodulesingress
[schema-reference-onprem]: https://docs.sighup.io/docs/reference/onpremises#specdistributionmodulesingress

<!-- </SD-DOCS> -->

## License

For license details please see [LICENSE](../../LICENSE)
