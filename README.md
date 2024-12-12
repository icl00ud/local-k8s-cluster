<h2 align="center">Local K8s Cluster with VirtualBox, Vagrant, and Ansible</h2>

<p align="center">Hey there! This repo has everything you need to set up a local Kubernetes cluster with VirtualBox, Vagrant, and Ansible. Perfect for testing and experimenting!</p>

## 📝 Table of Contents

- [Prerequisites](#prerequisites)
- [How to Use](#how_to_use)
- [Observations](#observations)

## 💾 Prerequisites <a name="prerequisites"></a>

Here's what you need to get started:

- **VirtualBox** (latest version)
- **[Vagrant](https://developer.hashicorp.com/vagrant/install)** (latest version)
- **[Ansible](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu)** (to set up the VMs)

## ⚙️ How to Use <a name="how_to_use"></a>

### 1. Clone this repo

```bash
git clone https://github.com/icl00ud/local-k8s-cluster.git
```

### 2. Navigate to the folder and run the script

```bash
cd local-k8s-cluster
chmod +x ./start-k8s-cluster.sh # give permission to exec
./start-k8s-cluster.sh
```

If everything goes well, you'll see a success message with your cluster info. If not, it'll show the error.

## ⚠️ Observations <a name="observations"></a>

Want to tweak the resource settings? Head over to the `Vagrantfile` where you can adjust vCPUs, memory, network, and the number of worker and master nodes.

Got questions? Ping me at israelschroederm@gmail.com 😉

## 🛠️ Technologies Used

<div align="center">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/ansible/ansible-original.svg" height="75" width="90" alt="ansible logo" style="margin-right: 25px;" />
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/vagrant/vagrant-original.svg" height="75" width="90" alt="vagrant logo" style="margin-right: 25px;" />
</div>
