<h3 align="center">Local K8s Cluster with VirtualBox, Vagrant, and Ansible</h3>


---

<p align="center"> This repository contains the necessary files to provision and configure three nodes using VirtualBox, Vagrant, and Ansible. The goal is to create a local development environment for testing and experimenting with Kubernetes.</p>

## 📝 Table of Contents

- [Getting Started](#getting_started)
- [Prerequisites](#prerequisites)

## 🏁 Getting Started <a name = "getting_started"></a>

## Prerequisites <a name = "prerequisites"></a>

What things you need to install the software and how to install them.

- **VirtualBox** (latest version)
- **[Vagrant](https://developer.hashicorp.com/vagrant/install)** (latest version)
- **[Ansible](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu)** (to configure the VMs)

## How to use

### 1. Clone this repository

```bash
git clone https://github.com/icl00ud/local-k8s-cluster.git
```

### 2. Navigate to the folder and run the script

```bash
cd local-k8s-cluster
chmod +x ./start-k8s-cluster.sh # give permission to exec
./start-k8s-cluster.sh
```


If everything is ok, you will see a success message and the info about your cluster. Otherwise, it will print the error.
