#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-default}"

# Recreates a generic secret from KEY=VALUE pairs.
replace_secret() {
  local name="$1"; shift
  local args=()
  for pair in "$@"; do args+=(--from-literal="${pair}"); done

  kubectl -n "${NAMESPACE}" delete secret "${name}" --ignore-not-found
  kubectl -n "${NAMESPACE}" create secret generic "${name}" "${args[@]}"
}

echo "== predictor-api-secret (namespace: ${NAMESPACE})"
read -rp "POSTGRES_USER: " POSTGRES_USER
read -rsp "POSTGRES_PASSWORD: " POSTGRES_PASSWORD
echo
replace_secret predictor-api-secret \
  "POSTGRES_USER=${POSTGRES_USER}" \
  "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}"

echo
echo "== predictor-keycloak-secret (namespace: ${NAMESPACE})"
echo "Database credentials for the 'keycloak' database."
read -rp "KC_DB_USERNAME: " KC_DB_USERNAME
read -rsp "KC_DB_PASSWORD: " KC_DB_PASSWORD
echo
echo "Temporary admin, only created on Keycloak's first start. Replace it with a permanent admin afterwards."
read -rp "KC_BOOTSTRAP_ADMIN_USERNAME [admin]: " KC_BOOTSTRAP_ADMIN_USERNAME
KC_BOOTSTRAP_ADMIN_USERNAME="${KC_BOOTSTRAP_ADMIN_USERNAME:-admin}"
read -rsp "KC_BOOTSTRAP_ADMIN_PASSWORD: " KC_BOOTSTRAP_ADMIN_PASSWORD
echo
replace_secret predictor-keycloak-secret \
  "KC_DB_USERNAME=${KC_DB_USERNAME}" \
  "KC_DB_PASSWORD=${KC_DB_PASSWORD}" \
  "KC_BOOTSTRAP_ADMIN_USERNAME=${KC_BOOTSTRAP_ADMIN_USERNAME}" \
  "KC_BOOTSTRAP_ADMIN_PASSWORD=${KC_BOOTSTRAP_ADMIN_PASSWORD}"

echo "✅ Secrets created."
