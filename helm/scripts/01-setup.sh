#!/usr/bin/env bash
set -euo pipefail
echo "This script performs local chart checks only; it does not change the cluster."
command -v helm >/dev/null || { echo "Helm not found. See README.md."; exit 1; }
helm version
helm lint ./charts/my-first-chart
helm template demo ./charts/my-first-chart -n helm-demo
