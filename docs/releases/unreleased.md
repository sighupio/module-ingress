# Ingress Module Release (Unreleased)

Welcome to the latest release of `Ingress` module of [`SIGHUP Distribution`](https://github.com/sighupio/fury-distribution) maintained by team SIGHUP.

This release switches the `nginx-ingress` controller image to a custom build of the Chainguard fork, produced in-house in [`container-image-sync`](https://github.com/sighupio/container-image-sync). The published tag now carries a `-chainguard` suffix (`v1.15.5-chainguard`).

This release also validates the module against **Kubernetes 1.35.x** (added to the e2e test matrix).

## Component Images 🚢

| Component          | Supported Version                                                                                       | Previous Version |
| ------------------ | ------------------------------------------------------------------------------------------------------- | :--------------: |
| `aws-cert-manager` | N.A.                                                                                                    |   `No update`    |
| `aws-external-dns` | N.A.                                                                                                    |   `No update`    |
| `cert-manager`     | [`v1.19.2`](https://cert-manager.io/docs/releases/release-notes/release-notes-1.19/)                    |   `No update`    |
| `dual-nginx`       | [`v1.15.5-chainguard`](https://github.com/chainguard-forks/ingress-nginx/releases/tag/controller-v1.15.5) |    `v1.14.3`     |
| `external-dns`     | [`v0.20.0`](https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.20.0)                       |   `No update`    |
| `forecastle`       | [`v1.0.159`](https://github.com/stakater/Forecastle/releases/tag/v1.0.159)                              |   `No update`    |
| `haproxy`          | [`v3.2.4`](https://github.com/haproxytech/kubernetes-ingress/releases/tag/v3.2.4)                       |   `No update`    |
| `nginx`            | [`v1.15.5-chainguard`](https://github.com/chainguard-forks/ingress-nginx/releases/tag/controller-v1.15.5) |    `v1.15.1`     |

> Please refer the individual release notes to get a more detailed information on each release.

## Update Guide 🦮

### Process

To upgrade this core module from `v5.0.1` to `v5.1.0`, you need to download this new version, and apply the instructions below.

```bash
kustomize build <your-project-path> | kubectl apply -f -
```
