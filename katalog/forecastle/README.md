# Forecastle

<!-- <SD-DOCS> -->

## Overview

[Forecastle][forecastle-page] provides a handy dashboard that lists all the applications running on Kubernetes and exposed through an Ingress, grouped by namespace. It acts as a cluster entry point to discover running applications. Forecastle discovers applications through annotations on Ingress objects (for example `forecastle.stakater.com/expose: "true"`) and through the `ForecastleApp` custom resource.

## Upstream project

This package is based on the upstream [Forecastle][forecastle-github].

## Deployment

This package is deployed as part of **Ingress Module** when you create a cluster with `furyctl`.

You can customize it under `spec.distribution.modules.ingress.forecastle` in your `furyctl.yaml`. See the [module documentation](../../README.md) and the configuration reference ([EKSCluster][schema-reference-eks], [KFDDistribution][schema-reference-kfd], [OnPremises][schema-reference-onprem]) for the available options.

<!-- Links -->

[forecastle-page]: https://github.com/stakater/Forecastle
[forecastle-github]: https://github.com/stakater/Forecastle
[schema-reference-eks]: https://docs.sighup.io/docs/reference/ekscluster#specdistributionmodulesingress
[schema-reference-kfd]: https://docs.sighup.io/docs/reference/kfddistribution#specdistributionmodulesingress
[schema-reference-onprem]: https://docs.sighup.io/docs/reference/onpremises#specdistributionmodulesingress

<!-- </SD-DOCS> -->

## License

For license details please see [LICENSE](../../LICENSE)
