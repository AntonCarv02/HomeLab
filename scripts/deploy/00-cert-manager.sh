#!/usr/bin/env bash
set -euo pipefail

# Deploys cert-manager (Helm) and the ClusterIssuer.
# cert-manager MUST install first: its Helm chart provides the CRDs that the
# ClusterIssuer (and Gateway annotations) depend on. Server-dry-run of the
# ClusterIssuer therefore happens AFTER the Helm install.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

CERT_MANAGER_VERSION="v1.20.2"
VALUES="$ROOT_DIR/k8s/cert-manager/cert-manager-values.yml"
CLUSTER_ISSUER="$ROOT_DIR/k8s/cert-manager/cluster-issuer.yml"

log "=== cert-manager ==="

# 1. Client dry-run the ClusterIssuer (offline structural check only).
#    NOTE: this does NOT validate the cert-manager CRD schema yet (CRDs not
#    installed until the Helm step below). Server-dry-run after Helm covers that.
client_dry_run "$CLUSTER_ISSUER"

# 2. Helm install cert-manager (idempotent). Establishes the CRDs.
log "Installing cert-manager $CERT_MANAGER_VERSION via Helm (OCI chart)"
helm upgrade --install cert-manager \
  oci://quay.io/jetstack/charts/cert-manager \
  --version "$CERT_MANAGER_VERSION" \
  --namespace cert-manager \
  --create-namespace \
  -f "$VALUES" \
  --wait

# 3. Server dry-run the ClusterIssuer — now the cert-manager CRDs exist,
#    so this validates against the real ClusterIssuer schema + admission.
server_dry_run "$CLUSTER_ISSUER"

# 4. Real apply.
apply_manifests "$CLUSTER_ISSUER"

log "cert-manager done"