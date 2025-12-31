# Ingress Module Release v5.0.0


Welcome to the latest release of `Ingress` module of [`SIGHUP Distribution`](https://github.com/sighupio/fury-distribution) maintained by team SIGHUP.

This release updates several packages included in the ingress module, to officially support Kubernetes v1.34.x. 

## Component versions 🚢

| Component          | Supported Version                                                                        | Previous Version |
| ------------------ | ---------------------------------------------------------------------------------------- | :--------------: |
| `aws-cert-manager` | N.A.                                                                                     |   `No update`    |
| `aws-external-dns` | N.A.                                                                                     |   `No update`    |
| `cert-manager`     | [`v1.19.2`](https://cert-manager.io/docs/releases/release-notes/release-notes-1.19/)     |     `v1.18.2`    |
| `dual-nginx`       | [`v1.14.1`](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v1.14.1) |     `v1.13.3`    |
| `external-dns`     | [`v0.20.0`](https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.20.0)        |     `v0.18.0`    |
| `forecastle`       | [`v1.0.159`](https://github.com/stakater/Forecastle/releases/tag/v1.0.159)               |    `v1.0.157`    |
| `nginx`            | [`v1.14.1`](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v1.14.1) |     `v1.13.3`    |

> Please refer the individual release notes to get a more detailed information on each release.

## New features 🎉

### NGINX Ingress Controller v1.14.1

For detailed information about changes in NGINX Ingress Controller v1.14.1, please refer to the upstream changelogs [v1.14.0](https://github.com/kubernetes/ingress-nginx/blob/main/changelog/controller-1.14.0.md) and [v1.14.1](https://github.com/kubernetes/ingress-nginx/blob/main/changelog/controller-1.14.1.md)

### cert-manager v1.19.2

Updated to cert-manager v1.19.2.

For detailed information about changes in cert-manager v1.19.2, please refer to the [upstream release notes](https://cert-manager.io/docs/releases/release-notes/release-notes-1.19/).

### external-dns v0.20.0

Updated to external-dns v0.20.0.

For detailed information about changes in external-dns v0.20.0, please refer to the [upstream release notes](https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.20.0).

### forecastle v1.0.159

Updated to forecastle v1.0.159.

For detailed information about changes in forecastle v1.0.159, please refer to the [upstream release notes](https://github.com/stakater/Forecastle/releases/tag/v1.0.159).

## Breaking changes 💔

⚠️ **WARNING**

### External DNS IPv6 ExternalIP as default

External DNS v0.19.0 introduced a potentially breaking change in the Kubernetes clusters where Nodes are using both IPv4 and IPv6 networking, and are using two different Network Interfaces, so that the Node's InternalIP and ExternalIP are different. 
Se the [related PR](https://github.com/kubernetes-sigs/external-dns/pull/5575) for additional info.

### Cert manager new metrics label

From cert-manager 1.19, the certmanager_http_acme_client_request_count metric doesn't use the "path" label anymore. The included cert-manager dashboard has been updated accordingly. 

## Kubernetes support 🚢

| Kubernetes Version |   Compatibility    | Notes           |
| ------------------ | :----------------: | --------------- |
| `1.31.x`           | :white_check_mark: | No known issues |
| `1.32.x`           | :white_check_mark: | No known issues |
| `1.33.x`           | :white_check_mark: | No known issues |
| `1.34.x`           | :white_check_mark: | No known issues |

## Upgrade Guide 🦮

> ℹ️ **INFO**
>
> This update guide is for users of the module and not of the Distribution or users still on furyctl legacy.
> If you are a SD user, the update is performed automatically by furyctl.

### Process

To upgrade this core module from `v4.1.1` to `v5.0.0`, you need to download this new version and apply the standard update process.

```bash
kustomize build <your-project-path> | kubectl apply -f - --server-side
```

The upgrade process is seamless and does not require any manual intervention.