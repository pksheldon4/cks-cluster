#!/bin/sh

# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/

### setup terminal
apt-get install -y bash-completion binutils
echo 'colorscheme ron' >> ~/.vimrc
echo 'set tabstop=2' >> ~/.vimrc
echo 'set shiftwidth=2' >> ~/.vimrc
echo 'set expandtab' >> ~/.vimrc
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'alias c=clear' >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc
sed -i '1s/^/force_color_prompt=yes\n/' ~/.bashrc

# Update all existing packages since the vagrant box might not have the latest updates
apt-get update && apt-get upgrade -y

### install k8s and docker
apt-get remove -y docker.io kubelet kubeadm kubectl kubernetes-cni
apt-get autoremove -y
apt-get install -y etcd-client vim build-essential

systemctl daemon-reload
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
KUBE_VERSION=1.19.6
apt-get update
apt-get install -y docker.io kubelet=${KUBE_VERSION}-00 kubeadm=${KUBE_VERSION}-00 kubectl=${KUBE_VERSION}-00 kubernetes-cni=0.8.7-00
apt-mark hold kubeadm kubelet kubectl
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker

# start docker on reboot
systemctl enable docker

docker info | grep -i "storage"
docker info | grep -i "cgroup"

systemctl enable kubelet && systemctl start kubelet


### init k8s
rm /root/.kube/config
kubeadm reset -f
IFNAME=$1
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
kubeadm init --kubernetes-version=${KUBE_VERSION} \
  --pod-network-cidr=192.168.11.0/16 \
  --apiserver-advertise-address=$ADDRESS \
  --ignore-preflight-errors=NumCPU \
  --skip-token-print

mkdir -p ~/.kube
cp -i /etc/kubernetes/admin.conf ~/.kube/config
cp ~/.kube/config /vagrant/kube.config

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

#echo
#echo "### COMMAND TO ADD A WORKER NODE ###"
kubeadm token create --print-join-command --ttl 0 > /vagrant/scripts/kubeadm-join.sh
chmod +x /vagrant/scripts/kubeadm-join.sh
