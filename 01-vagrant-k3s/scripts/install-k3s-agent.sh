#!/usr/bin/env bash
# Installs K3s in agent (worker) mode and joins it to the benyS control-plane.
set -euo pipefail

NODE_IP="${NODE_IP:?NODE_IP not set}"
SERVER_IP="${SERVER_IP:?SERVER_IP not set}"
FLANNEL_IFACE="${FLANNEL_IFACE:-enp0s8}"
TOKEN_FILE="/vagrant/.node-token"

echo ">>> Waiting for the control-plane token from benyS..."
until [ -f "${TOKEN_FILE}" ]; do
  sleep 2
done
K3S_TOKEN="$(cat "${TOKEN_FILE}")"

echo ">>> Installing K3s agent on ${NODE_IP}, joining https://${SERVER_IP}:6443"

curl -sfL https://get.k3s.io | \
  K3S_URL="https://${SERVER_IP}:6443" \
  K3S_TOKEN="${K3S_TOKEN}" \
  INSTALL_K3S_EXEC="agent --node-ip=${NODE_IP} --flannel-iface=${FLANNEL_IFACE}" \
  sh -

echo ">>> Agent provisioned. Verify from benyS with: kubectl get nodes -o wide"
