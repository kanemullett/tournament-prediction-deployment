#!/usr/bin/env bash
set -euo pipefail

SECRET_NAME="predictor-api-secret"
NAMESPACE="${NAMESPACE:-default}"

echo "Creating/updating secret: ${SECRET_NAME} in namespace: ${NAMESPACE}"

read -rp "POSTGRES_USER: " POSTGRES_USER
read -rsp "POSTGRES_PASSWORD: " POSTGRES_PASSWORD
echo

kubectl -n "${NAMESPACE}" delete secret "${SECRET_NAME}" --ignore-not-found

kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
  --from-literal=POSTGRES_USER="${POSTGRES_USER}" \
  --from-literal=POSTGRES_PASSWORD="${POSTGRES_PASSWORD}"

echo "✅ Secret created."