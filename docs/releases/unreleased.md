# Ingress Module Release (Unreleased)

Welcome to the latest release of `Ingress` module of [`SIGHUP Distribution`](https://github.com/sighupio/fury-distribution) maintained by team SIGHUP.

This release addresses two security vulnerabilities in ingress-nginx where a combination of Ingress annotations can be used to inject configuration into nginx, leading to arbitrary code execution in the context of the ingress-nginx controller and disclosure of Secrets accessible to the controller.

- [CVE-2026-4342](https://groups.google.com/g/kubernetes-security-announce/c/E9bLHAD6-eg): ingress-nginx comment-based nginx configuration injection (CVSS 8.8 - CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H)
- [CVE-2026-3288](https://groups.google.com/g/kubernetes-security-announce/c/hIAkgZb8MJ0): ingress-nginx rewrite-target nginx configuration injection (CVSS 8.8 - CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H)

## Component Images 🚢

| Component          | Supported Version                                                                        | Previous Version |
| ------------------ | ---------------------------------------------------------------------------------------- | :--------------: |
| `aws-cert-manager` | N.A.                                                                                     |   `No update`    |
| `aws-external-dns` | N.A.                                                                                     |   `No update`    |
| `cert-manager`     | [`v1.19.2`](https://cert-manager.io/docs/releases/release-notes/release-notes-1.19/)     |    `No update`     |
| `dual-nginx`       | [`v1.14.3`](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v1.14.3) |    `No update`     |
| `external-dns`     | [`v0.20.0`](https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.20.0)        |    `No update`     |
| `forecastle`       | [`v1.0.159`](https://github.com/stakater/Forecastle/releases/tag/v1.0.159)               |    `No update`    |
| `haproxy`          | [`v3.2.4`](https://github.com/haproxytech/kubernetes-ingress/releases/tag/v3.2.4)        |      `No update`       |
| `nginx`            | [`v1.15.1`](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v1.15.1) |    `v1.14.3`     |

> Please refer the individual release notes to get a more detailed information on each release.

## Update Guide 🦮

### Process

To upgrade this core module from `v5.0.0` to `v5.0.1`, you need to download this new version, and apply the instructions below.

```bash
kustomize build <your-project-path> | kubectl apply -f -
```
