# HAProxy Ingress Controller

<!-- <SD-DOCS> -->

[HAProxy Ingress Controller][haproxy-page] is an Ingress Controller for [HAProxy][haproxy-main] load balancer, it manages HAProxy in a Kubernetes native manner. This package supports both single and dual (internal/external) deployment modes.

## Requirements

- Kubernetes >= `1.31.0`
- Kustomize >= `v5.6.0`
- `cert-manager`

## Image repository and tag

- HAProxy Ingress Controller image: `registry.sighup.io/fury/haproxytech/kubernetes-ingress:3.2.4`
- HAProxy Ingress Controller repo: [https://github.com/haproxytech/kubernetes-ingress](https://github.com/haproxytech/kubernetes-ingress)

## Configuration

HAProxy Ingress Controller is deployed with the following default configuration:

- SSL redirect enabled with status code `301`
- Deployed as a `DaemonSet`
- Metrics exposed via ServiceMonitor
- Grafana dashboard included
- TLS default certificate managed by cert-manager

## Deployment

> You'll need to have deployed [`cert-manager`](../cert-manager/) first, the TLS default certificate requires cert-manager issuers.

### Single deployment

Deploys a single HAProxy Ingress Controller with IngressClass `haproxy`.

```bash
kustomize build katalog/haproxy/single | kubectl apply -f -
```

### Dual deployment

Deploys two HAProxy Ingress Controllers:
- **External** controller with IngressClass `haproxy-external` for public traffic
- **Internal** controller with IngressClass `haproxy-internal` for private traffic

```bash
kustomize build katalog/haproxy/dual | kubectl apply -f -
```

## Common customizations

Both single and dual packages are deployed as `DaemonSet`, meaning they will deploy 1 ingress-controller pod on every worker node.

If your cluster has `infra` nodes, you should patch the DaemonSet adding the `NodeSelector` for the `infra` nodes. You can do this using the following kustomize patch:

**Single:**

```yaml
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: haproxy-ingress
spec:
  template:
    spec:
      nodeSelector:
        node-kind.sighup.io/infra: ""
```

**Dual:**

```yaml
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: haproxy-ingress-external
spec:
  template:
    spec:
      nodeSelector:
        node-kind.sighup.io/infra: ""
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: haproxy-ingress-internal
spec:
  template:
    spec:
      nodeSelector:
        node-kind.sighup.io/infra: ""
```

## Alerts

The following Prometheus [alerts][prometheus-alerts] are defined for this package.

### HAProxy Ingress Controller Alert Rules

| Parameter                                | Description                                                                                                           | Severity | Interval |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | -------- | :------: |
| `HaproxyIngressTargetDown`               | This alert fires if Prometheus target discovery was not able to reach haproxy-ingress metrics in the last 15 minutes. | critical |   15m    |
| `HaproxyHighHttp4xxErrorRateBackend`     | This alert fires if the 4xx error rate measured on a 2 minute window exceeds 10% for 5 minutes.                       | warning  |    5m    |
| `HaproxyHighHttp5xxErrorRateBackend`     | This alert fires if the 5xx error rate measured on a 2 minute window exceeds 10% for 10 minutes.                      | critical |   10m    |
| `HaproxyServerResponseErrors`            | This alert fires if a specific backend server has response error rate exceeding 5% for 5 minutes.                     | warning  |    5m    |
| `HaproxyBackendConnectionErrors`         | This alert fires if connection errors exceed 100 per second for 5 minutes on a backend.                               | warning  |    5m    |
| `HaproxyBackendNoAliveServers`           | This alert fires immediately when a backend has no healthy servers available.                                         | critical |    0m    |
| `HaproxyBackendPendingRequests`          | This alert fires if requests have been queued for a backend for more than 5 minutes.                                  | warning  |    5m    |
| `HaproxyFrontendSecurityBlockedRequests` | This alert fires if more than 10 connections per second are being denied on a frontend for 2 minutes.                 | warning  |    2m    |
| `HaproxyBackendLatencyHigh`              | This alert fires if average backend response time exceeds 5 seconds for 10 minutes.                                   | warning  |   10m    |
| `HaproxyBackendLatencyCritical`          | This alert fires if average total time exceeds 10 seconds for 10 minutes.                                             | critical |   10m    |
| `HaproxyServerHealthcheckFailure`        | This alert fires if health check failures are detected for a server over a 5 minute period.                           | warning  |    5m    |
| `HaproxyIngressConfigSyncFailed`         | This alert fires if the ingress configuration sync failed in the last 10 minutes.                                     | warning  |   10m    |

<!-- Links -->
[haproxy-page]: https://github.com/haproxytech/kubernetes-ingress
[haproxy-main]: https://www.haproxy.org
[prometheus-alerts]: https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/

<!-- </SD-DOCS> -->

## License

For license details please see [LICENSE](../../LICENSE)
