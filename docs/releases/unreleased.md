# Ingress Module Release vTBD

Welcome to the latest release of `Ingress` module of [`SIGHUP Distribution`](https://github.com/sighupio/distribution) maintained by team SIGHUP.

This release bumps the version of the Ingress NGINX controller image to include fixes the the nginx2root CVEs: CVE-2026-123007 CVE-2026-123634 CVE-2026-123633 CVE-2026-121810 CVE-2026-113425

## Component Images 🚢

| Component          | Supported Version                                                                                           | Previous Version |
| ------------------ | ----------------------------------------------------------------------------------------------------------- | :--------------: |
| `aws-cert-manager` | N.A.                                                                                                        |   `No update`    |
| `aws-external-dns` | N.A.                                                                                                        |   `No update`    |
| `cert-manager`     | [`v1.21.2`](https://cert-manager.io/docs/releases/release-notes/release-notes-1.21/)                        |    `v1.20.2`     |
| `external-dns`     | [`v0.21.0`](https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.21.0)                           |   `No update`    |
| `forecastle`       | [`v1.0.159`](https://github.com/stakater/Forecastle/releases/tag/v1.0.159)                                  |   `No update`    |
| `haproxy`          | [`v3.2.15`](https://github.com/haproxytech/kubernetes-ingress/releases/tag/v3.2.15)                         |     `v3.2.8`     |
| `nginx`            | [`v1.15.16-chainguard`](https://github.com/chainguard-forks/ingress-nginx/releases/tag/controller-v1.15.16) |    `v1.15.10`    |
| `dual-nginx`       | [`v1.15.16-chainguard`](https://github.com/chainguard-forks/ingress-nginx/releases/tag/controller-v1.15.16) |    `v1.15.10`    |

## Fixes 🐞

- [#187](https://github.com/sighupio/module-ingress/pull/187) Bump Ingress NGINX Controller version to 1.15.16-chainguard to fix several nginx2root CVEs

## Breaking Changes 💔

None
