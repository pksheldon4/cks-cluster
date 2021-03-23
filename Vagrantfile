# -*- mode: ruby -*-
# vi: set ft=ruby :
VM_ID = "vagrant"
NUM_WORKER_NODES = 2
IP_NW = "192.168.11."
IP_START=20

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.box_check_update = true

# Single Control-Plane node  
  config.vm.define "#{VM_ID}-master" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.name = "#{VM_ID}-master"
      vb.memory = 8192
      vb.cpus = 2
    end
    node.vm.hostname = "#{VM_ID}-master"
    node.vm.network :private_network, bridge: "en0: Wi-Fi (AirPort)", ip: "192.168.11.10"

    node.vm.provision "setup-hosts", :type => "shell", :path => "scripts/setup-hosts.sh" do |s|
      s.args = ["enp0s8"]
    end
    node.vm.provision "setup-dns", type: "shell", :path => "scripts/update-dns.sh"
    node.vm.provision "install-ntp", type: "shell", :path => "scripts/install-ntp.sh"
    node.vm.provision "init-k8s", type: "shell", :path => "scripts/install_master.sh" do |s|
      s.args = ["enp0s8"]
    end
    node.vm.provision "authorize-root", type: "shell", :path => "scripts/authorize-root.sh"
  end

# Worker nodes
  (1..NUM_WORKER_NODES).each do |i|
    config.vm.define "#{VM_ID}-worker-#{i}" do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.name = "#{VM_ID}-worker-#{i}"
        vb.memory = 4096
        vb.cpus = 2
      end
      node.vm.hostname = "#{VM_ID}-worker-#{i}"
      node.vm.network :private_network, bridge: "en0: Wi-Fi (AirPort)", ip: IP_NW + "#{IP_START + i}"

      node.vm.provision "setup-hosts", :type => "shell", :path => "scripts/setup-hosts.sh" do |s|
        s.args = ["enp0s8"]
      end
      
      node.vm.provision "setup-dns", type: "shell", :path => "scripts/update-dns.sh"
      node.vm.provision "install-ntp", type: "shell", :path => "scripts/install-ntp.sh"
      node.vm.provision "install_worker", type: "shell", :path => "scripts/install_worker.sh"
      node.vm.provision "authorize-root", type: "shell", :path => "scripts/authorize-root.sh"
      node.vm.provision "join-cluster", type: "shell", :path => "scripts/kubeadm-join.sh"
    end
  end
end