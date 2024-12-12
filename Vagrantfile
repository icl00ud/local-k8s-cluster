Vagrant.configure("2") do |config|
  # Prevent VMs from being created in parallel to avoid provisioning conflicts
  ENV["VAGRANT_NO_PARALLEL"] = "true"

  # Base box to use for all VMs
  config.vm.box = "ubuntu/focal64"

  # ====================
  # Master Node Configuration
  # ====================
  config.vm.define "kube-master" do |master|
    master.vm.hostname = "kube-master"
    master.vm.network "private_network", ip: "192.168.56.10"
    master.vm.network "public_network", ip: "192.168.1.10"
  
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 4096
      vb.cpus = 2
    end
  
    master.vm.provision "ansible" do |ansible|
      ansible.playbook = "./ansible/playbooks/kube-master.yml"
      ansible.inventory_path = "./ansible/inventories/hosts.ini"
      ansible.limit = "kube-master"
      ansible.become = true
    end
  end

  # ====================
  # Worker Nodes Configuration
  # ====================
  (1..1).each do |i|
    config.vm.define "kube-node-#{i}" do |node|
      node.vm.hostname = "kube-node-#{i}"
      
      # Assign unique static IPs to worker nodes
      node.vm.network "private_network", ip: "192.168.56.#{10 + i}"
      
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 2048  # Allocate 2GB RAM; modify as needed
        vb.cpus = 2       # Assign 2 CPU cores
      end

      # SSH options for compatibility
      node.ssh.extra_args = [
        '-o', 'PubkeyAcceptedKeyTypes=+ssh-rsa',
        '-o', 'HostKeyAlgorithms=+ssh-rsa'
      ]

      # Provision each worker node using Ansible
      node.vm.provision "ansible" do |ansible|
        ansible.playbook = "./ansible/playbooks/kube-node.yml"
        ansible.inventory_path = "./ansible/inventories/hosts.ini"
        ansible.limit = "kube-node-#{i}"
        ansible.become = true
      end
    end
  end
end
