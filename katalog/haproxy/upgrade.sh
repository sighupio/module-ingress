#!/bin/bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Remember to change the helm chart version
VERSION=1.47.4

CHART_REPO="https://haproxytech.github.io/helm-charts"
CHART_NAME="kubernetes-ingress"
NAMESPACE="ingress-haproxy"

generate_mode() {
  local mode_name=$1
  local values_files=$2
  local output_dir=$3

  echo ""
  echo "Creating $mode_name manifests"

  local temp_dir=$(mktemp -d)
  cd "$temp_dir"

  helm template haproxy-ingress "$CHART_NAME" \
    --repo "$CHART_REPO" \
    --namespace "$NAMESPACE" \
    --version "$VERSION" \
    --api-versions monitoring.coreos.com/v1 \
    $values_files | yq -s '.kind + "-" + .metadata.name'

  mkdir -p "$output_dir"
  # Rename .yml to .yaml and move to target dir
  for f in *.yml; do
    mv "$f" "$output_dir/${f%.yml}.yaml"
  done

  cd - > /dev/null
  rm -rf "$temp_dir"

  echo "Created manifests in $output_dir"
}


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Single
generate_mode "single" \
  "--values $SCRIPT_DIR/MAINTENANCE.values.yaml" \
  "$SCRIPT_DIR/single"

# Dual internal
generate_mode "internal" \
  "--values $SCRIPT_DIR/MAINTENANCE.values.yaml --values $SCRIPT_DIR/MAINTENANCE.internal.values.yaml" \
  "$SCRIPT_DIR/dual/internal"

# Dual external
generate_mode "external" \
  "--values $SCRIPT_DIR/MAINTENANCE.values.yaml --values $SCRIPT_DIR/MAINTENANCE.external.values.yaml" \
  "$SCRIPT_DIR/dual/external"

echo ""
echo "Adding license headers"
go install github.com/google/addlicense@v1.1.1
addlicense -c "SIGHUP s.r.l" -y "2017-present" -v -l bsd single/ dual/

echo ""
echo "Upgrade complete"