#!/usr/bin/env bash
# Shared deploy helpers. Sourced by the per-service scripts and the orchestrator.
# Not meant to be run directly.

# --- logging ---
log()  { printf '\033[1;34m[deploy]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }

# --- repo sync ---
# On manual runs, pull latest before doing anything else.
# Skipped in CI — actions/checkout already has the verified commit.
if [[ "${CI:-false}" != "true" ]]; then
  _repo_root="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
  log "Pulling latest (CI not set — manual run)"
  git -C "$_repo_root" pull
  unset _repo_root
fi

# --- env loading ---
# Loads .env into the environment if present (local runs).
# In CI the vars are already injected as environment variables, so .env is absent
# and this is skipped — same script works in both contexts.
load_env() {
  if [[ -f .env ]]; then
    log "Loading .env"
    set -a
    # shellcheck disable=SC1091
    source .env
    set +a
  else
    log ".env not found — assuming variables are already in the environment (CI)"
  fi
}

# --- validation ---
# Client-side dry-run: offline structural/schema check, no cluster contact.
client_dry_run() {
  log "Client dry-run: $*"
  for f in "$@"; do
    kubectl apply --dry-run=client -f "$f" >/dev/null
  done
}

# Server-side dry-run: validates against the live cluster's real CRDs/admission,
# without persisting. Run only after any CRD-providing step (e.g. Helm) has run.
server_dry_run() {
  log "Server dry-run: $*"
  for f in "$@"; do
    kubectl apply --dry-run=server -f "$f" >/dev/null
  done
}

# --- apply ---
# Applies manifests for real. Files listed in NEEDS_SUBST are piped through
# envsubst (scoped to named vars only) so placeholders like ${IMMICH_DB_PASSWORD}
# are substituted from the environment; all others applied as-is.
apply_manifests() {
  log "Applying: $*"
  for f in "$@"; do
    if [[ " ${NEEDS_SUBST:-} " == *" $f "* ]]; then
      envsubst "$SUBST_VARS" < "$f" | kubectl apply -f -
    else
      kubectl apply -f "$f"
    fi
  done
}