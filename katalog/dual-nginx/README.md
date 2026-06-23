# Ingress NGINX Dual

<!-- <SD-DOCS> -->

## Overview

Ingress NGINX is an Ingress Controller for the [NGINX][nginx-page] web server and reverse proxy, managing NGINX in a Kubernetes native manner. This package deploys two NGINX controllers: one with ingress class `external` to serve public traffic, and one with ingress class `internal` to serve internal traffic. The default configuration sets a maximum client request body size of `10m`, a `301` redirect status code, Prometheus metrics scraping, and a validating admission webhook for ingress definitions.

## Upstream project

This package is based on the upstream [Ingress NGINX][nginx-github]. SIGHUP rebuilds the controller on top of [Chainguard][chainguard] hardened, minimal container images (hence the `-chainguard` image tags), so the deployed images are not the upstream ones.

## Deployment

This package is deployed as part of **Ingress Module** when you create a cluster with `furyctl`.

You can customize it under `spec.distribution.modules.ingress.nginx` in your `furyctl.yaml`. See the [module documentation](../../README.md) and the configuration reference ([EKSCluster][schema-reference-eks], [KFDDistribution][schema-reference-kfd], [OnPremises][schema-reference-onprem]) for the available options.

<!-- Links -->

[nginx-page]: https://nginx.org
[nginx-github]: https://github.com/kubernetes/ingress-nginx
[chainguard]: https://www.chainguard.dev
[schema-reference-eks]: https://docs.sighup.io/docs/reference/ekscluster#specdistributionmodulesingress
[schema-reference-kfd]: https://docs.sighup.io/docs/reference/kfddistribution#specdistributionmodulesingress
[schema-reference-onprem]: https://docs.sighup.io/docs/reference/onpremises#specdistributionmodulesingress

<!-- </SD-DOCS> -->

## License

For license details please see [LICENSE](../../LICENSE)
