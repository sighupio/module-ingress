#!/usr/bin/env bats
# shellcheck disable=SC2154

# Load helper libraries
load './helper/bats-support/load'
load './helper/bats-assert/load'
load ./helper

# Function to build and apply kustomize manifests
# Uses server-side apply to avoid annotation size limits with large ConfigMaps (e.g., Grafana dashboards)
apply() {
  kustomize build "${1}" >&2
  kustomize build "${1}" | kubectl apply --server-side -f -
}

# Function to wait for all pods to reach a stable state
# Excludes Job pods (crdjob) since they are expected to terminate with Completed or Error
wait_for_settlement() {
  max_retry=0
  echo "=====" $max_retry "=====" >&2
  while kubectl get pods --all-namespaces | grep -v "crdjob" | grep -ie "\(Pending\|Error\|CrashLoop\|ContainerCreating\)" >&2; do
    [ $max_retry -lt "${1}" ] || (kubectl describe all --all-namespaces >&2 && return 1)
    sleep 10 && echo "# waiting..." $max_retry >&3
    max_retry=$((max_retry + 1))
  done
}

# Helper function to check HTTP response code and content
# Usage: check_http_and_content <port> <path> <expected_code> <expected_content> [hostname]
check_http_and_content() {
  local port=$1
  local path=$2
  local expected_code=$3
  local expected_content=$4
  local hostname=${5:-localhost}
  local response_file="/tmp/curl_response_$$"

  http_code=$(curl -s -o "$response_file" -w "%{http_code}" --resolve "${hostname}:${port}:127.0.0.1" "http://${hostname}:${port}${path}")

  if [ "$http_code" != "$expected_code" ]; then
    echo "Expected HTTP $expected_code but got $http_code for ${hostname}:${port}${path}" >&2
    rm -f "$response_file"
    return 1
  fi

  if [ -n "$expected_content" ]; then
    if ! grep -q "$expected_content" "$response_file" 2>/dev/null; then
      echo "Expected content '$expected_content' not found in response" >&2
      echo "Response was: $(cat "$response_file")" >&2
      rm -f "$response_file"
      return 1
    fi
  fi

  rm -f "$response_file"
  return 0
}

# ========================================
# Installation Phase - All components
# ========================================

# Apply monitoring CRDs from an external source
@test "Apply Prometheus monitoring CRDs" {
  info
  kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v2.0.0/katalog/prometheus-operator/crds/0prometheusruleCustomResourceDefinition.yaml
  kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v2.0.0/katalog/prometheus-operator/crds/0servicemonitorCustomResourceDefinition.yaml
}

# Apply cert-manager CRDs from local files
@test "Apply cert-manager CRDs" {
  info
  kubectl apply -f katalog/cert-manager/cert-manager-controller/crd.yml
}

# Install cert-manager using kustomize
@test "Install cert-manager" {
  info
  install() {
    apply katalog/cert-manager
  }
  loop_it install 45 10
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

# Install dual-nginx using kustomize
@test "Install dual-nginx ingress controller" {
  info
  install() {
    apply katalog/dual-nginx
  }
  loop_it install 30 5
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

# Install haproxy dual using kustomize
@test "Install haproxy dual ingress controller" {
  info
  install() {
    apply katalog/haproxy/dual
  }
  loop_it install 45 10
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

# Install forecastle using kustomize
@test "Install forecastle" {
  info
  install() {
    apply katalog/forecastle
  }
  loop_it install 30 5
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

# Deploy test backend services (4 deployments with unique content)
@test "Deploy test backend services" {
  info
  install() {
    kubectl apply -f katalog/tests/test-services.yaml
  }
  loop_it install 30 5
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

# Wait for all resources to be applied and settled
@test "Wait for cluster pods to settle" {
  info
  wait_for_settlement 48
}

# Wait for test service deployments to be ready
@test "Wait for test backend services to be ready" {
  info
  kubectl wait --for=condition=available --timeout=120s deployment/test-nginx-external -n default
  kubectl wait --for=condition=available --timeout=120s deployment/test-nginx-internal -n default
  kubectl wait --for=condition=available --timeout=120s deployment/test-haproxy-external -n default
  kubectl wait --for=condition=available --timeout=120s deployment/test-haproxy-internal -n default
}

# Deploy test ingress resources (4 ingresses with path stripping)
@test "Deploy test ingress resources" {
  info
  install() {
    kubectl apply -f katalog/tests/test-ingresses.yaml
  }
  loop_it install 30 5
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

# ========================================
# Routing Tests - Verify each controller serves its paths
# ========================================

# Verify nginx-external serves correct content
@test "Routing: nginx-external controller serves /nginx-external path" {
  info
  test() {
    check_http_and_content "${EXTERNAL_PORT}" "/nginx-external" "200" "NGINX-EXTERNAL" "nginx-ext.127.0.0.1.nip.io"
  }
  loop_it test 30 2
  [[ "${loop_it_result}" -eq 0 ]]
}

# Verify nginx-internal serves correct content
@test "Routing: nginx-internal controller serves /nginx-internal path" {
  info
  test() {
    check_http_and_content "${INTERNAL_PORT}" "/nginx-internal" "200" "NGINX-INTERNAL" "nginx-int.127.0.0.1.nip.io"
  }
  loop_it test 30 2
  [[ "${loop_it_result}" -eq 0 ]]
}

# Verify haproxy-external serves correct content
@test "Routing: haproxy-external controller serves /haproxy-external path" {
  info
  test() {
    check_http_and_content "${HAPROXY_EXTERNAL_PORT}" "/haproxy-external" "200" "HAPROXY-EXTERNAL" "haproxy-ext.127.0.0.1.nip.io"
  }
  loop_it test 45 2
  [[ "${loop_it_result}" -eq 0 ]]
}

# Verify haproxy-internal serves correct content
@test "Routing: haproxy-internal controller serves /haproxy-internal path" {
  info
  test() {
    check_http_and_content "${HAPROXY_INTERNAL_PORT}" "/haproxy-internal" "200" "HAPROXY-INTERNAL" "haproxy-int.127.0.0.1.nip.io"
  }
  loop_it test 45 2
  [[ "${loop_it_result}" -eq 0 ]]
}

# ========================================
# Isolation Tests - Cross-controller (nginx ↔ haproxy)
# ========================================

# Verify nginx-external path is not served by haproxy-external (wrong hostname)
@test "Isolation: haproxy-external rejects nginx paths" {
  info
  test() {
    http_code=$(curl --resolve "nginx-ext.127.0.0.1.nip.io:${HAPROXY_EXTERNAL_PORT}:127.0.0.1" "http://nginx-ext.127.0.0.1.nip.io:${HAPROXY_EXTERNAL_PORT}/nginx-external" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "404" ]; then return 1; fi
  }
  loop_it test 30 2
  [[ "${loop_it_result}" -eq 0 ]]
}

# Verify haproxy-external path is not served by nginx-external (wrong hostname)
@test "Isolation: nginx-external rejects haproxy paths" {
  info
  test() {
    http_code=$(curl --resolve "haproxy-ext.127.0.0.1.nip.io:${EXTERNAL_PORT}:127.0.0.1" "http://haproxy-ext.127.0.0.1.nip.io:${EXTERNAL_PORT}/haproxy-external" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "404" ]; then return 1; fi
  }
  loop_it test 30 2
  [[ "${loop_it_result}" -eq 0 ]]
}

# Verify nginx-internal path is not served by haproxy-internal (wrong hostname)
@test "Isolation: haproxy-internal rejects nginx paths" {
  info
  test() {
    http_code=$(curl --resolve "nginx-int.127.0.0.1.nip.io:${HAPROXY_INTERNAL_PORT}:127.0.0.1" "http://nginx-int.127.0.0.1.nip.io:${HAPROXY_INTERNAL_PORT}/nginx-internal" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "404" ]; then return 1; fi
  }
  loop_it test 30 2
  [[ "${loop_it_result}" -eq 0 ]]
}

# Verify haproxy-internal path is not served by nginx-internal (wrong hostname)
@test "Isolation: nginx-internal rejects haproxy paths" {
  info
  test() {
    http_code=$(curl --resolve "haproxy-int.127.0.0.1.nip.io:${INTERNAL_PORT}:127.0.0.1" "http://haproxy-int.127.0.0.1.nip.io:${INTERNAL_PORT}/haproxy-internal" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "404" ]; then return 1; fi
  }
  loop_it test 30 2
  [[ "${loop_it_result}" -eq 0 ]]
}

# ========================================
# Isolation Tests - Internal/External scope separation
# ========================================

# Verify nginx-external path is not served by nginx-internal (wrong controller)
@test "Isolation: nginx-internal rejects external paths" {
  info
  test() {
    http_code=$(curl --resolve "nginx-ext.127.0.0.1.nip.io:${INTERNAL_PORT}:127.0.0.1" "http://nginx-ext.127.0.0.1.nip.io:${INTERNAL_PORT}/nginx-external" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "404" ]; then return 1; fi
  }
  loop_it test 30 2
  [[ "${loop_it_result}" -eq 0 ]]
}

# Verify nginx-internal path is not served by nginx-external (wrong controller)
@test "Isolation: nginx-external rejects internal paths" {
  info
  test() {
    http_code=$(curl --resolve "nginx-int.127.0.0.1.nip.io:${EXTERNAL_PORT}:127.0.0.1" "http://nginx-int.127.0.0.1.nip.io:${EXTERNAL_PORT}/nginx-internal" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "404" ]; then return 1; fi
  }
  loop_it test 30 2
  [[ "${loop_it_result}" -eq 0 ]]
}

# Verify haproxy-external path is not served by haproxy-internal (wrong controller)
@test "Isolation: haproxy-internal rejects external paths" {
  info
  test() {
    http_code=$(curl --resolve "haproxy-ext.127.0.0.1.nip.io:${HAPROXY_INTERNAL_PORT}:127.0.0.1" "http://haproxy-ext.127.0.0.1.nip.io:${HAPROXY_INTERNAL_PORT}/haproxy-external" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "404" ]; then return 1; fi
  }
  loop_it test 30 2
  [[ "${loop_it_result}" -eq 0 ]]
}

# Verify haproxy-internal path is not served by haproxy-external (wrong controller)
@test "Isolation: haproxy-external rejects internal paths" {
  info
  test() {
    http_code=$(curl --resolve "haproxy-int.127.0.0.1.nip.io:${HAPROXY_EXTERNAL_PORT}:127.0.0.1" "http://haproxy-int.127.0.0.1.nip.io:${HAPROXY_EXTERNAL_PORT}/haproxy-internal" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "404" ]; then return 1; fi
  }
  loop_it test 30 2
  [[ "${loop_it_result}" -eq 0 ]]
}

# ========================================
# HAProxy Resource Verification Tests
# ========================================

# Verify haproxy-external IngressClass exists
@test "Verify haproxy-external IngressClass exists" {
  run kubectl get ingressclass haproxy-external
  assert_success
}

# Verify haproxy-internal IngressClass exists
@test "Verify haproxy-internal IngressClass exists" {
  run kubectl get ingressclass haproxy-internal
  assert_success
}

# Verify ingress-haproxy namespace exists
@test "Verify ingress-haproxy namespace exists" {
  run kubectl get namespace ingress-haproxy
  assert_success
}

# Verify HAProxy External DaemonSet exists
@test "Verify HAProxy External DaemonSet exists" {
  run kubectl get daemonset -n ingress-haproxy haproxy-ingress-external
  assert_success
}

# Verify HAProxy Internal DaemonSet exists
@test "Verify HAProxy Internal DaemonSet exists" {
  run kubectl get daemonset -n ingress-haproxy haproxy-ingress-internal
  assert_success
}

# ========================================
# Cert-Manager Verification Tests
# ========================================

# Verify the installation of cert-manager CRDs
@test "Verify certificates.cert-manager.io CRD exists" {
  run kubectl get crd certificates.cert-manager.io
  assert_success
}

# Check that cert-manager webhook deployment is up
@test "Verify cert-manager webhook installation" {
  run kubectl get deployment cert-manager-webhook -n cert-manager
  assert_success
}

# Ensure cert-manager namespace exists
@test "Verify cert-manager namespace creation" {
  run kubectl get namespace cert-manager
  assert_success
  assert_output --partial "cert-manager"
}

# Confirm production ClusterIssuer for Let's Encrypt is created
@test "Verify letsencrypt-prod ClusterIssuer creation" {
  run kubectl get clusterissuer letsencrypt-prod
  assert_success
}

# Confirm staging ClusterIssuer for Let's Encrypt is created
@test "Verify letsencrypt-staging ClusterIssuer creation" {
  run kubectl get clusterissuer letsencrypt-staging
  assert_success
}

# Create and verify a self-signed issuer
@test "Create and verify selfsigned-issuer Issuer" {
  cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-issuer
  namespace: cert-manager
spec:
  selfSigned: {}
EOF
  run kubectl wait --for=condition=Ready --timeout=60s issuer/selfsigned-issuer -n cert-manager
  assert_success
}

# Create and verify a certificate using the self-signed issuer
@test "Create and verify selfsigned-cert Certificate" {
  cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: selfsigned-cert
  namespace: cert-manager
spec:
  secretName: selfsigned-cert-tls
  issuerRef:
    name: selfsigned-issuer
    kind: Issuer
  commonName: example.com
  dnsNames:
  - example.com
EOF
  run kubectl wait --for=condition=Ready --timeout=60s certificate/selfsigned-cert -n cert-manager
  assert_success
}

# Verify ACME HTTP01 solver image uses SIGHUP registry
@test "Verify ACME HTTP01 solver image uses SIGHUP registry" {
  # Extract the ACME solver image from cert-manager deployment and verify it uses our registry
  solver_image=$(kubectl get deployment cert-manager -n cert-manager -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -o 'registry\.sighup\.io/fury/jetstack/cert-manager-acmesolver[^[:space:]]*' | head -1)

  if [[ "$solver_image" == registry.sighup.io/fury/jetstack/cert-manager-acmesolver* ]]; then
    echo "ACME solver image uses our registry: $solver_image"
  else
    echo "ACME solver image not from our registry or not found: $solver_image"
    exit 1
  fi
}

# Verify the existence of ValidatingWebhookConfiguration for cert-manager
@test "Verify cert-manager-webhook ValidatingWebhookConfiguration exists" {
  run kubectl get validatingwebhookconfiguration cert-manager-webhook
  assert_success
}

# Verify the existence of MutatingWebhookConfiguration for cert-manager
@test "Verify cert-manager-webhook MutatingWebhookConfiguration exists" {
  run kubectl get mutatingwebhookconfiguration cert-manager-webhook
  assert_success
}

# Check if cert-manager ServiceAccount is present
@test "Verify cert-manager ServiceAccount exists" {
  run kubectl get serviceaccount -n cert-manager cert-manager
  assert_success
}

# Ensure Roles and RoleBindings are properly configured
@test "Verify cert-manager:leaderelection Role and RoleBinding exist" {
  run kubectl get role -n cert-manager cert-manager:leaderelection
  assert_success

  run kubectl get rolebinding -n cert-manager cert-manager:leaderelection
  assert_success
}

# Verify ClusterRoles and ClusterRoleBindings for cert-manager
@test "Verify cert-manager-controller-approve ClusterRole and ClusterRoleBinding exist" {
  run kubectl get clusterrole cert-manager-controller-approve:cert-manager-io
  assert_success

  run kubectl get clusterrolebinding cert-manager-controller-approve:cert-manager-io
  assert_success
}

# Confirm that cert-manager Services are configured correctly
@test "Verify cert-manager and cert-manager-webhook Services exist" {
  run kubectl get service -n cert-manager cert-manager
  assert_success

  run kubectl get service -n cert-manager cert-manager-webhook
  assert_success
}

# Ensure cert-manager certificates are properly issued
@test "Verify selfsigned-cert Certificate exists" {
  run kubectl get certificate -n cert-manager selfsigned-cert
  assert_success
}

# Confirm ConfigMaps are created for cert-manager
@test "Verify cert-manager-dashboard ConfigMap exists" {
  run kubectl get configmap -n cert-manager cert-manager-dashboard
  assert_success

}

# Verify the existence of ServiceMonitor for cert-manager
@test "Verify cert-manager ServiceMonitor exists" {
  run kubectl get servicemonitor -n cert-manager cert-manager
  assert_success
}

# Ensure Deployments are created for cert-manager components
@test "Verify cert-manager, cainjector and webhook Deployments exist" {
  run kubectl get deployment -n cert-manager cert-manager
  assert_success

  run kubectl get deployment -n cert-manager cert-manager-cainjector
  assert_success

  run kubectl get deployment -n cert-manager cert-manager-webhook
  assert_success
}

# Verify ReplicaSets for cert-manager deployments
@test "Verify cert-manager, cainjector and webhook ReplicaSets exist" {
  run kubectl get replicaset -n cert-manager -l app=cert-manager
  assert_success

  run kubectl get replicaset -n cert-manager -l app=cert-manager-cainjector
  assert_success

  run kubectl get replicaset -n cert-manager -l app=cert-manager-webhook
  assert_success
}

# Check role assignments using kubectl auth can-i
@test "Verify cert-manager ServiceAccount RBAC permissions" {
  run kubectl auth can-i get certificates.cert-manager.io --as=system:serviceaccount:cert-manager:cert-manager
  assert_success
  assert_output --partial "yes"

  run kubectl auth can-i get certificaterequests.cert-manager.io --as=system:serviceaccount:cert-manager:cert-manager-cainjector
  if [ "$status" -ne 0 ]; then
    echo "Skipping cert-manager-cainjector role check as it is expected to fail."
  else
    assert_success
    assert_output --partial "yes"
  fi

  run kubectl auth can-i get challenges.acme.cert-manager.io --as=system:serviceaccount:cert-manager:cert-manager-webhook
  if [ "$status" -ne 0 ]; then
    echo "Skipping cert-manager-webhook role check as it is expected to fail."
  else
    assert_success
    assert_output --partial "yes"
  fi
}
