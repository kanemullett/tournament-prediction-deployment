#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/do/deploy.yaml

echo "Waiting for ingress-nginx controller to be ready..."
kubectl rollout status deployment -n ingress-nginx ingress-nginx-controller --timeout=5m

echo "Ingress service:"
kubectl get svc -n ingress-nginx ingress-nginx-controller