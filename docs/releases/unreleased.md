# Ingress Module Release v4.1.0


Welcome to the latest release of `Ingress` module of [`SIGHUP Distribution`](https://github.com/sighupio/fury-distribution) maintained by team SIGHUP.

This release updates the NGINX Ingress Controller to version 1.13.1 for improved security, performance, and compatibility. It also introduces support for Kubernetes 1.33 while maintaining compatibility with previous versions.

## Component versions 🚢

| Component          | Supported Version                                                                        | Previous Version |
| ------------------ | ---------------------------------------------------------------------------------------- | :--------------: |
| `aws-cert-manager` | N.A.                                                                                     |   `No update`    |
| `aws-external-dns` | N.A.                                                                                     |   `No update`    |
| `cert-manager`     | [`v1.18.2`](https://cert-manager.io/docs/releases/release-notes/release-notes-1.18/)     |   `v1.17.1`      |
| `dual-nginx`       | [`v1.13.1`](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v1.13.1) |     `1.12.1`     |
| `external-dns`     | [`v0.16.1`](https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.16.1)        |   `No update`    |
| `forecastle`       | [`v1.0.156`](https://github.com/stakater/Forecastle/releases/tag/v1.0.156)               |   `No update`    |
| `nginx`            | [`v1.13.1`](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v1.13.1) |     `1.12.1`     |

> Please refer the individual release notes to get a more detailed information on each release.

## New features 🎉

### Kubernetes 1.33 Support

This release adds support for Kubernetes 1.33.x, expanding the compatibility matrix to support Kubernetes versions 1.29 through 1.33.

### NGINX Ingress Controller v1.13.1

Updated to NGINX Ingress Controller v1.13.1.

For detailed information about changes in NGINX Ingress Controller v1.13.1, please refer to the [upstream changelog](https://github.com/kubernetes/ingress-nginx/blob/main/changelog/controller-1.13.1.md).

### cert-manager v1.18.2

Updated to cert-manager v1.18.2.

For detailed information about changes in cert-manager v1.18.2, please refer to the [upstream release notes](https://cert-manager.io/docs/releases/release-notes/release-notes-1.18/).

## Breaking changes 💔

### cert-manager v1.18 ACME HTTP01 Challenge PathType Change

cert-manager v1.18 introduced a breaking change where ACME HTTP01 challenge ingress paths now use `PathType: Exact` instead of `PathType: ImplementationSpecific` for enhanced security and reliable handling across different ingress controllers.

**Compatibility Issue**: This change conflicts with nginx-ingress controller versions >=1.12.0 when the `strict-validate-path-type` option is enabled (default since v1.12.0). The strict validation rejects ACME challenge paths like `/.well-known/acme-challenge/<TOKEN>` when using `PathType: Exact`, causing certificate provisioning to fail.

**Workaround Applied**: This module includes an automatic workaround by setting the cert-manager feature gate `ACMEHTTP01IngressPathTypeExact=false`, which reverts to the previous `PathType: ImplementationSpecific` behavior while maintaining ACME HTTP01 challenge functionality.

For more details, see the [cert-manager v1.18 release notes](https://cert-manager.io/docs/releases/release-notes/release-notes-1.18/#acme-http01-challenge-paths-now-use-pathtype-exact-in-ingress-routes).

## Kubernetes support 🚢

| Kubernetes Version |   Compatibility    | Notes           |
| ------------------ | :----------------: | --------------- |
| `1.29.x`           | :white_check_mark: | No known issues |
| `1.30.x`           | :white_check_mark: | No known issues |
| `1.31.x`           | :white_check_mark: | No known issues |
| `1.32.x`           | :white_check_mark: | No known issues |
| `1.33.x`           | :white_check_mark: | No known issues |

## Upgrade Guide 🦮

> ℹ️ **INFO**
>
> This update guide is for users of the module and not of the Distribution or users still on furyctl legacy.
> If you are a SD user, the update is performed automatically by furyctl.

### Process

To upgrade this core module from `v4.0.0` to `v4.1.0`, you need to download this new version and apply the standard update process.

```bash
kustomize build <your-project-path> | kubectl apply -f - --server-side
```

The upgrade process is seamless and does not require any manual intervention.