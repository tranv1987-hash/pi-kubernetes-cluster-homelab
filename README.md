# pi-kubernetes-cluster-homelab
A functional 3-node Kubernetes cluster built on Raspberry Pi 4B hardware, demonstrating practical Linux administration, networking fundamentals, and foundational concepts of distributed systems and fault tolerance.
# Distributed Systems & Network Fundamentals for 3 Node Kubernetes Homelab Project

This repository documents the end-to-end process of building a functional Kubernetes cluster on low-cost hardware. The project serves as a practical demonstration of advanced Linux administration, networking concepts, and foundational concepts of distributed systems and fault tolerance, which are vital for a career in **Network Administration** and system operations.

---

Key Skills Demonstrated

This project emphasizes practical experience working with infrastructure:

* **Advanced Linux Administration:** Debugging and resolving kernel-level Cgroup memory issues (`cgroup_memory`) and permanent ZRAM swap disabling across all nodes.
* **Networking Fundamentals (OSI Layers 3 & 4):** **Static IP configuration**, PoE switch management, and deploying a Container Network Interface (**Flannel**).
* **Container Orchestration:** Installation and management of a stable Kubernetes Control Plane (`kubeadm`, v1.28.15) and node maintenance.
* **Distributed Systems:** Implementing a multi-node cluster structure to ensure service **fault tolerance** and availability.

* **Infrastructure-as-Code (IaC):** Cluster components and application deployment are defined declaratively using **YAML manifests**.

---

Hardware and Network Architecture
| Component | Quantity | Model / Description ||
| :--- | :--- | :--- |
| **Nodes** | 3 | Raspberry Pi 4 Model B (4GB RAM) |
| **Power/Networking** | 1 | TP-Link TL-SG605P 4-Port Gigabit PoE+ Switch |

| **Power Adapter** | 3 | Raspberry Pi PoE+ Hat - For Power Delivery
| **OS** | 3 | Raspberry Pi OS (64-bit Debian-based) |
**Internal Static IP Scheme:** : (Specific addresses have been masked for security)
| Hostname | Role | Static Internal IP |
| :--- | :--- | :--- |



| `pi-master-0` | Control Plane | `10.0.0.X` MASKED |

| `pi-worker-1` | Worker | `10.0.0.Y` (Masked) |

| `pi-worker-2` | Worker | `10.0.0.Z` (Masked) |

---

## Step-by-Step Installation & Troubleshooting

This section describes the critical steps taken and the emphasis on system-level troubleshooting needed for stability.
#### 1. System Preparation and Debugging (The Critical Fixes)
The biggest challenge, technically, was to resolve the pre-flight checks that were stopping cluster initialization. This needed deep diving into the kernel configuration.
* **Enable Cgroups:** Edited `/boot/firmware/cmdline.txt` on **all three nodes** to resolve the fatal `missing required cgroups: memory` error.

```bash
# Added at the end of the line in cmdline.txt:
cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory
```
* **Disable ZRAM Swap Permanently:** Masked the ZRAM service on **all three nodes** to prevent the kernel from utilizing swap, resolving the `swap is enabled` warning that prevents the Kubelet from running.

```bash

sudo swapoff -a
sudo systemctl mask systemd-zram-setup@zram0.service
sudo reboot
```
Proof:

#### 2. Installation of Kubernetes Components

* Installed Container Runtime, Containerd and Kubernetes packages v1.28.15 via apt on all nodes.
* Prevented uncontrolled updates using `apt-mark hold`:
```bash
sudo apt-mark hold kubelet kubeadm kubectl
```
#### 3. Initialization of Clusters and Node Join
* **Master Initialization (`pi-master-0`):** (IP and CIDR masked for security)
```bash
sudo kubeadm init --control-plane-endpoint=INTERNAL_MASTER_IP --pod-network-cidr=10.244.0.0/16
```
* **CNI Deployment - Flannel:** Created the pod networking layer on the master node.
```bash

kubectl apply -f [https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml](https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml)

```
* **Worker Joining:** The cluster join command was executed on `pi-worker-1` and `pi-worker-2`. (Token and hash masked for security).
```bash
sudo kubeadm join INTERNAL_MASTER_IP:6443 --token [SECRET_TOKEN]
--discovery-token-ca-cert-hash sha256:[SECRET_HASH]
``` #### 4. Final Verification of Clusters The cluster was verified as stable and running after successful CNI deployment: ```bash $ kubectl get nodes NAME          STATUS   ROLES           AGE   VERSION pi-master-0   Ready    control-plane. v1.28.15 pi-worker-1   Ready    <none>. v1.28.15 pi-worker-2   Ready    <none>. v1.28.15
