#!/usr/bin/env bash
# Installs K3s in server (control-plane) mode.
# NODE_IP / FLANNEL_IFACE are injected by the Vagrantfile's shell provisioner.
set -euo pipefail

NODE_IP="${NODE_IP:?NODE_IP not set}"
FLANNEL_IFACE="${FLANNEL_IFACE:-enp0s8}"
TOKEN_FILE="/vagrant/.node-token"
KUBECONFIG_FILE="/vagrant/.kubeconfig"

echo ">>> Installing K3s server on ${NODE_IP} (flannel iface: ${FLANNEL_IFACE})"

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --node-ip=${NODE_IP} \
  --bind-address=${NODE_IP} \
  --advertise-address=${NODE_IP} \
  --tls-san=${NODE_IP} \
  --flannel-iface=${FLANNEL_IFACE} \
  --write-kubeconfig-mode=644" sh -

echo ">>> Waiting for node token..."
until [ -f /var/lib/rancher/k3s/server/node-token ]; do
  sleep 2
done

# Share the join token + kubeconfig with the host (and the agent VM) via the
# synced /vagrant folder so the worker node can join automatically.
cp /var/lib/rancher/k3s/server/node-token "${TOKEN_FILE}"
cp /etc/rancher/k3s/k3s.yaml "${KUBECONFIG_FILE}"
sed -i "s/127.0.0.1/${NODE_IP}/" "${KUBECONFIG_FILE}"
chmod 644 "${TOKEN_FILE}" "${KUBECONFIG_FILE}"

# Convenience for the vagrant user (k3s also ships its own bundled kubectl).
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /home/vagrant/.bashrc
echo 'alias k=kubectl' >> /home/vagrant/.bashrc

echo ">>> K3s server ready. Verify from inside the VM with: kubectl get nodes -o wide"
