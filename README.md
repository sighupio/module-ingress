<!-- markdownlint-disable MD033 -->
<h1 align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/white-logo.png">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/black-logo.png">
  <img alt="Shows a black logo in light color mode and a white one in dark color mode." src="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/white-logo.png">
</picture><br/>
  Ingress Module
</h1>
<!-- markdownlint-enable MD033 -->

![Release](https://img.shields.io/badge/Latest%20Release-v5.1.0-blue)
![License](https://img.shields.io/github/license/sighupio/fury-kubernetes-ingress?label=License)
![Slack](https://img.shields.io/badge/slack-@kubernetes/fury-yellow.svg?logo=slack&label=Slack)

<!-- <SD-DOCS> -->

**Ingress Module** provides Ingress Controllers to expose services and TLS certificate management solutions for [SIGHUP Distribution (SD)][kfd-repo].

If you are new to SD please refer to the [official documentation][kfd-docs] on how to get started with SD.

## Overview

**Ingress Module** uses CNCF recommended, Cloud Native projects, such as [Ingress NGINX][ingress-nginx-docs] and [HAProxy Ingress Controller][haproxy-ingress-docs] as URL path-based routing reverse proxies and load balancers, and [cert-manager][cert-manager-repo] to automate the issuing and renewal of TLS certificates from various issuing sources.

The module also includes additional tools like [Forecastle][forecastle-repo], a web-based global directory of all the services offered by your cluster, and [ExternalDNS][external-dns-docs] to manage DNS records natively from Kubernetes.

### Architecture

- The traffic from end users arrives first at a Load Balancer that distributes the traffic between the available Ingress Controllers (usually, one for each availability zone).
- Once the traffic reaches the Ingress Controller, the Ingress proxies the traffic to the Kubernetes service based on the URL path of the request.
- The `service` is a Kubernetes abstraction that makes the traffic arrive at the pods where the actual application is running, usually using `iptables` rules.

For more information, please refer to the Kubernetes Ingress [official documentation][kubernetes-ingress].

## Packages

The following packages are included in Ingress Module:

| Package                                       | Version              | Description                                                                                                                   |
| --------------------------------------------- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [nginx](katalog/nginx)                        | `v1.15.5-chainguard` | The NGINX Ingress Controller for Kubernetes provides delivery services for Kubernetes applications.                           |
| [dual-nginx](katalog/dual-nginx)              | `v1.15.5-chainguard` | Deploys two identical NGINX ingress controllers but with two different scopes: public/external and private/internal.          |
| [cert-manager](katalog/cert-manager)          | `v1.20.2`            | cert-manager is a Kubernetes add-on to automate the management and issuance of TLS certificates from various issuing sources. |
| [external-dns](katalog/external-dns)          | `v0.21.0`            | external-dns allows you to manage DNS records natively from Kubernetes.                                                       |
| [haproxy](katalog/haproxy)                    | `v3.2.8`             | The HAProxy Ingress Controller for Kubernetes, supporting single and dual deployment modes.                                   |
| [forecastle](katalog/forecastle)              | `v1.0.159`           | Forecastle gives you access to a control panel where you can see your ingresses and access them on Kubernetes.                |
| [aws-cert-manager](modules/aws-cert-manager)  | `-`                  | Terraform module for managing IAM permissions on AWS for cert-manager.                                                        |
| [aws-external-dns](modules/aws-external-dns)  | `-`                  | Terraform module for managing IAM permissions on AWS for external-dns.                                                        |

Click on each package to see its full documentation.

## Compatibility

| Kubernetes Version |   Compatibility    | Notes           |
| ------------------ | :----------------: | --------------- |
| `1.32.x`           | :white_check_mark: | No known issues |
| `1.33.x`           | :white_check_mark: | No known issues |
| `1.34.x`           | :white_check_mark: | No known issues |
| `1.35.x`           | :white_check_mark: | No known issues |

Check the [compatibility matrix][compatibility-matrix] for additional information about previous releases of the module.

## Usage

**Ingress Module** is part of SIGHUP Distribution (SD) and is deployed automatically by [`furyctl`][furyctl-repo] when you create or update a cluster. You don't need to download, vendor or install its packages manually.

### Configuration

The module is deployed with sensible defaults. Configuration is **optional**: you can customize its packages under `spec.distribution.modules.ingress` in your `furyctl.yaml`. If you omit the block, the defaults are applied.

```yaml
apiVersion: kfd.sighup.io/v1alpha2
kind: KFDDistribution
spec:
  distribution:
    modules:
      ingress:
        baseDomain: example.dev
        nginx:
          type: dual
          tls:
            provider: certManager
        certManager:
          clusterIssuer:
            name: letsencrypt
            email: example@sighup.io
            type: http01
        forecastle: {}
```

To use HAProxy as the ingress controller instead of NGINX, configure the `haproxy` block (and set `nginx.type: none`):

```yaml
apiVersion: kfd.sighup.io/v1alpha2
kind: KFDDistribution
spec:
  distribution:
    modules:
      ingress:
        baseDomain: example.dev
        nginx:
          type: none
        haproxy:
          type: dual
          tls:
            provider: certManager
        certManager:
          clusterIssuer:
            name: letsencrypt
            email: example@sighup.io
            type: http01
        forecastle: {}
```

See the configuration reference for your cluster kind for the full list of available options: [EKSCluster][schema-reference-eks], [KFDDistribution][schema-reference-kfd] or [OnPremises][schema-reference-onprem].

To install SD from scratch, follow the [Getting started][getting-started] guide.

<!-- Links -->

[kfd-repo]: https://github.com/sighupio/distribution
[furyctl-repo]: https://github.com/sighupio/furyctl
[kfd-docs]: https://docs.sighup.io/docs/distribution/
[schema-reference-eks]: https://docs.sighup.io/docs/reference/ekscluster#specdistributionmodulesingress
[schema-reference-kfd]: https://docs.sighup.io/docs/reference/kfddistribution#specdistributionmodulesingress
[schema-reference-onprem]: https://docs.sighup.io/docs/reference/onpremises#specdistributionmodulesingress
[getting-started]: https://docs.sighup.io/docs/getting-started/
[compatibility-matrix]: https://github.com/sighupio/module-ingress/blob/main/docs/COMPATIBILITY_MATRIX.md
[kubernetes-ingress]: https://kubernetes.io/docs/concepts/services-networking/ingress/
[ingress-nginx-docs]: https://github.com/kubernetes/ingress-nginx
[haproxy-ingress-docs]: https://github.com/haproxytech/kubernetes-ingress
[cert-manager-repo]: https://github.com/cert-manager/cert-manager
[external-dns-docs]: https://github.com/kubernetes-sigs/external-dns
[forecastle-repo]: https://github.com/stakater/Forecastle

<!-- </SD-DOCS> -->

<!-- <FOOTER> -->

## Contributing

Before contributing, please read first the [Contributing Guidelines](https://github.com/sighupio/distribution/blob/main/docs/CONTRIBUTING.md).

### Reporting Issues

In case you experience any problem with the module, please [open a new issue](https://github.com/sighupio/module-ingress/issues/new/choose).

## License

This module is open-source and it's released under the following [LICENSE](LICENSE).

<!-- </FOOTER> -->
