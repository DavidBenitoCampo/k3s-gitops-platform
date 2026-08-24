# Phase 1 — K3s + Vagrant (two-node cluster)

Two Ubuntu 24.04 VMs: a K3s control-plane (`benyS`) and a K3s agent (`benySW`),
wired together on a private network with a shared join-token handoff.

## Layout

```
01-vagrant-k3s/
├── Vagrantfile
├── scripts/
│   ├── install-k3s-server.sh
│   ├── install-k3s-agent.sh
│   └── install-kubectl.sh
└── .gitignore
```

## Usage

```bash
vagrant up            # brings up benyS, then benySW
vagrant ssh benyS
kubectl get nodes -o wide
```

Expected output: two `Ready` nodes — `benyS` as `control-plane,master`,
`benySW` with no role (worker).

## Design notes

- **Passwordless SSH** comes for free from Vagrant's key insertion
  (`config.ssh.insert_key`, on by default) — no extra config needed.
- **Token handoff**: the server writes its join token to
  `/vagrant/.node-token`, the Vagrant synced folder shared by both VMs and
  the host. The agent polls for that file before installing. Fine for a
  local demo — just don't commit `.node-token` (see `.gitignore`).
- **`--flannel-iface=enp0s8`**: the classic K3s + Vagrant/VirtualBox gotcha.
  Without pinning it, flannel can bind to the NAT interface (`enp0s3`)
  instead of the private network, silently breaking pod-to-pod traffic
  across nodes. Run `ip a` on a fresh box to confirm the interface name if
  you switch providers (libvirt tends to use `enp1s0`, etc.).
- **Provider**: written for VirtualBox. Swap the `vb.` block for `libvirt.`
  (or your provider of choice) if you're not on VirtualBox — the network/IP
  config stays the same.

## Troubleshooting

- Nodes stuck `NotReady`: check `journalctl -u k3s` (server) /
  `journalctl -u k3s-agent` (agent).
- Agent never joins: confirm `/vagrant/.node-token` exists on benyS and is
  readable from benySW: `vagrant ssh benySW -c "cat /vagrant/.node-token"`.
