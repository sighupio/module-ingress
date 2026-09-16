# Ingress Module Release vTBD

Welcome to the latest release of `Ingress` module of [`SIGHUP Distribution`](https://github.com/sighupio/fury-distribution) maintained by team SIGHUP.

This release also validates the module against Kubernetes 1.36, removes the support for Kubernetes 1.32 and bumps the packages. See the maxtrix below.

## Fixes 🐞

- [#185](https://github.com/sighupio/module-ingress/pull/185) Updates HAProxy Ingress alerts to include information about the affected application, avoid duplicate alerts from controller replicas, and monitor configuration sync failures through the admin endpoint.

## Breaking Changes 💔

### HAProxy Ingress alerts renamed

HAProxy Ingress alert names now start with `HaproxyIngress`:

- `HaproxyHighHttp5xxErrorRateBackend` becomes `HaproxyIngressHighHttp5xxErrorRateBackend`.
- `HaproxyServerResponseErrors` becomes `HaproxyIngressServerResponseErrors`.
- `HaproxyBackendConnectionErrors` becomes `HaproxyIngressBackendConnectionErrors`.
- `HaproxyBackendPendingRequests` becomes `HaproxyIngressBackendPendingRequests`.
- `HaproxyServerHealthcheckFailure` becomes `HaproxyIngressServerHealthcheckFailure`.
- `HaproxyFrontendSecurityBlockedRequests` becomes `HaproxyIngressFrontendSecurityBlockedRequests`.
- `HaproxyBackendLatencyHigh` becomes `HaproxyIngressBackendLatencyHigh`.

### TokenRequest removed

The module removes the `cert-manager-tokenrequest` `Role` and `RoleBinding`. Issuers using `serviceAccountRef.name: cert-manager` must use a dedicated ServiceAccount with the required RBAC or grant `serviceaccounts/token: create` to the controller ServiceAccount.

### ACME Challenge and Order permissions restricted

The `cert-manager-edit` ClusterRole removes `create` on ACME `Challenge` resources and `create`, `patch`, and `update` on ACME `Order` resources. Custom resources that performs these operations must use a dedicated RBAC.

### Metrics Service port renamed

The cert-manager controller Service metrics port is renamed from `tcp-prometheus-servicemonitor` to `http-metrics`. Custom configurations must reference `http-metrics`.

## Component Images 🚢

| Component          | Supported Version                                                                                       | Previous Version |
| ------------------ | ------------------------------------------------------------------------------------------------------- | :--------------: |
| `aws-cert-manager` | N.A.                                                                                                    |   `No update`    |
| `aws-external-dns` | N.A.                                                                                                    |   `No update`    |
| `cert-manager`     | [`v1.21.2`](https://cert-manager.io/docs/releases/release-notes/release-notes-1.21/)                    |   `v1.20.2`    |
| `dual-nginx`       | [`v1.15.10-chainguard`](https://github.com/chainguard-forks/ingress-nginx/releases/tag/controller-v1.15.10) |    `v1.15.5`     |
| `external-dns`     | [`v0.21.0`](https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.21.0)                       |   `v0.20.0`    |
| `forecastle`       | [`v1.0.159`](https://github.com/stakater/Forecastle/releases/tag/v1.0.159)                              |   `No update`    |
| `haproxy`          | [`v3.2.15`](https://github.com/haproxytech/kubernetes-ingress/releases/tag/v3.2.15)                       |    `v3.2.8`      |
| `nginx`            | [`v1.15.10-chainguard`](https://github.com/chainguard-forks/ingress-nginx/releases/tag/controller-v1.15.10) |    `v1.15.5`     |

> Please refer the individual release notes to get a more detailed information on each release.

## Update Guide 🦮

> ℹ️ **INFO**
>
> This update guide is for users of the module and not of the Distribution or users still on furyctl legacy.
> If you are a SD user, the update is performed automatically by furyctl.

### Process

To upgrade this core module from `v5.1.0` to `vTBD`, complete the following steps.

1. If an `Issuer` or `ClusterIssuer` uses `serviceAccountRef.name: cert-manager`, create the replacement `Role` and `RoleBinding` granting `serviceaccounts/token: create`, or migrate the issuer to a dedicated ServiceAccount.

2. If needed, update custom Prometheus scrape configurations to use the controller Service port `http-metrics` instead of `tcp-prometheus-servicemonitor`.

3. If custom automation creates or modifies ACME `Challenge` or `Order` resources, grant it the required permissions with a dedicated RBAC role.

4. Delete the TokenRequest RBAC resources that are no longer managed by the module:

```bash
kubectl delete role cert-manager-tokenrequest -n cert-manager --ignore-not-found
kubectl delete rolebinding cert-manager-tokenrequest -n cert-manager --ignore-not-found
```

5. Apply the new manifests:

```bash
kustomize build <your-project-path> | kubectl apply -f - --server-side
```
