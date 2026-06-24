# HAProxy Ingress Controller

<!-- <SD-DOCS> -->

## Overview

HAProxy Kubernetes Ingress Controller is an Ingress Controller for the [HAProxy][haproxy-main] load balancer, managing HAProxy in a Kubernetes native manner. This package supports both single and dual (internal/external) deployment modes. The default configuration enables SSL redirect with status code `301`, deploys as a `DaemonSet`, exposes metrics via a ServiceMonitor, includes a Grafana dashboard, and uses a TLS default certificate managed by cert-manager.

## Upstream project

This package is based on the upstream [HAProxy Kubernetes Ingress Controller][haproxy-github].

## Deployment

This package is deployed as part of **Ingress Module** when you create a cluster with `furyctl`.

You can customize it under `spec.distribution.modules.ingress.haproxy` in your `furyctl.yaml`. See the [module documentation](../../README.md) and the configuration reference ([EKSCluster][schema-reference-eks], [KFDDistribution][schema-reference-kfd], [OnPremises][schema-reference-onprem]) for the available options.

<!-- Links -->

[haproxy-main]: https://www.haproxy.org
[haproxy-github]: https://github.com/haproxytech/kubernetes-ingress
[schema-reference-eks]: https://docs.sighup.io/docs/reference/ekscluster#specdistributionmodulesingress
[schema-reference-kfd]: https://docs.sighup.io/docs/reference/kfddistribution#specdistributionmodulesingress
[schema-reference-onprem]: https://docs.sighup.io/docs/reference/onpremises#specdistributionmodulesingress

<!-- </SD-DOCS> -->

## License

For license details please see [LICENSE](../../LICENSE)
