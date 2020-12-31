# -*- mode: ruby -*-
# vi: set ft=ruby :
VM_ID = "ckstest"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.box_check_update = true

# Single Control-Plane node  
  config.vm.define "#{VM_ID}-master" do |node|
      node.vm.provider "virtualbox" do |vb|
          vb.name = "#{VM_ID}-master1"
          vb.memory = 4096
          vb.cpus = 2
      end
      node.vm.hostname = "#{VM_ID}-master"
      node.vm.network :private_network, bridge: "en0: Wi-Fi (AirPort)", ip: "192.168.11.10"

      node.vm.provision "setup-hosts", :type => "shell", :path => "scripts/setup-hosts.sh" do |s|
        s.args = ["enp0s8"]
      end
      node.vm.provision "setup-dns", type: "shell", :path => "scripts/update-dns.sh"
      node.vm.provision "init-k8s", type: "shell", :path => "scripts/install_master.sh" do |s|
        s.args = ["enp0s8"]
      end
  end

# Worker nodes
  config.vm.define "#{VM_ID}-worker" do |node|
    node.vm.provider "virtualbox" do |vb|
        vb.name = "#{VM_ID}-worker"
        vb.memory = 4096
        vb.cpus = 2
    end
    node.vm.hostname = "#{VM_ID}-worker"
    node.vm.network :private_network, bridge: "en0: Wi-Fi (AirPort)", ip: "192.168.11.20"

    node.vm.provision "setup-hosts", :type => "shell", :path => "scripts/setup-hosts.sh" do |s|
      s.args = ["enp0s8"]
    end
    
    node.vm.provision "setup-dns", type: "shell", :path => "scripts/update-dns.sh"
    node.vm.provision "install_worker", type: "shell", :path => "scripts/install_worker.sh"
    node.vm.provision "join-cluster", type: "shell", :path => "scripts/kubeadm-join.sh"
  end
end
