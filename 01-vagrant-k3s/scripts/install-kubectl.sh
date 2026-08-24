#!/usr/bin/env bash
# Installs the upstream kubectl binary. K3s bundles its own, but installing
# kubectl explicitly keeps the tool visible and pinned to the latest stable
# release, matching the subject's "you will have to use kubectl" requirement.
set -euo pipefail

if command -v kubectl >/dev/null 2>&1; then
  echo ">>> kubectl already present, skipping."
  exit 0
fi

KUBECTL_VERSION="$(curl -sL https://dl.k8s.io/release/stable.txt)"
curl -sLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

echo ">>> kubectl ${KUBECTL_VERSION} installed."
