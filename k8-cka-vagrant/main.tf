terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
}

provider "local" {}

# Generate the Vagrantfile dynamically
resource "local_file" "vagrantfile" {
  filename = "${path.module}/Vagrantfile"
  content  = <<-EOT
 # -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box_check_update = false

  # Master node configuration
  config.vm.define "k8s-master" do |master|
    master.vm.box = "almalinux/9"
    master.vm.hostname = "k8s-master"
    master.vm.network "private_network", type: "dhcp"
    master.vm.provider "vmware_desktop" do |v|
      v.memory = 4096
      v.cpus = 2
    end

    master.vm.provision "shell", inline: <<-SHELL
      echo "Disabling swap..."
      swapoff -a
      sed -i '/swap/d' /etc/fstab

      echo "Enabling IP forwarding..."
      echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-k8s.conf
      sysctl --system

      echo "Installing dependencies..."
      dnf install -y epel-release yum-utils wget
      dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      dnf install -y containerd.io

      echo "Configuring containerd..."
      mkdir -p /etc/containerd
      containerd config default > /etc/containerd/config.toml
      sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
      sed -i 's|registry.k8s.io/pause:3.8|registry.k8s.io/pause:3.10|g' /etc/containerd/config.toml
      systemctl restart containerd
      systemctl enable containerd --now

      echo "Loading required kernel modules..."
      cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
      modprobe overlay
      modprobe br_netfilter

      echo "Applying sysctl settings for Kubernetes..."
      cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
      sysctl --system

      echo "Adding Kubernetes repository..."
      cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
EOF

      echo "Installing Kubernetes components..."
      dnf install -y kubeadm kubelet kubectl
      systemctl enable --now kubelet

      # Detect architecture and use appropriate CNI plugins
      ARCH=$(uname -m)
      echo "Detected architecture: $ARCH"

      echo "Installing CNI plugins for $ARCH architecture..."
      mkdir -p /opt/cni/bin
      
      if [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
        # ARM64 architecture
        wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-arm64-v1.3.0.tgz -O cni-plugins.tgz
      else
        # Default to AMD64
        wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz -O cni-plugins.tgz
      fi
      
      tar -C /opt/cni/bin -xzf cni-plugins.tgz
      rm -f cni-plugins.tgz

      echo "Pulling Kubernetes images..."
      kubeadm config images pull

      echo "Initializing Kubernetes cluster..."
      # Use pod CIDR 10.244.0.0/16 which is the default for Flannel
      kubeadm init --apiserver-advertise-address=$(hostname -I | awk '{print $2}') --pod-network-cidr=10.244.0.0/16

      echo "Setting up kubeconfig for vagrant user..."
      mkdir -p /home/vagrant/.kube
      cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
      chown -R vagrant:vagrant /home/vagrant/.kube

      echo "Deploying Flannel CNI..."
      kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

      echo "Generating join command for worker nodes..."
      kubeadm token create --print-join-command > /vagrant/k8s-join-command.sh
      chmod +x /vagrant/k8s-join-command.sh
    SHELL
  end

  # Worker nodes configuration
  ["k8s-worker1", "k8s-worker2"].each do |worker_name|
    config.vm.define worker_name do |worker|
      worker.vm.box = "almalinux/9"
      worker.vm.hostname = worker_name
      worker.vm.network "private_network", type: "dhcp"
      worker.vm.provider "vmware_desktop" do |v|
        v.memory = 4096
        v.cpus = 2
      end

      worker.vm.provision "shell", inline: <<-SHELL
        timeout=300
        elapsed=0
        while [ ! -f /vagrant/k8s-join-command.sh ]; do
          echo "Waiting for join command file..."
          sleep 10
          elapsed=$((elapsed + 10))
          if [ $elapsed -ge $timeout ]; then
            echo "ERROR: Timeout waiting for join command. Exiting."
            exit 1
          fi
        done
        echo "Join command found, proceeding with setup..."

        echo "Setting up repositories..."
        dnf install -y epel-release yum-utils wget
        dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        
        echo "Adding Kubernetes repository..."
        cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
EOF
        
        echo "Installing containerd..."
        dnf install -y containerd.io
        
        echo "Configuring containerd..."
        mkdir -p /etc/containerd
        containerd config default > /etc/containerd/config.toml
        sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
        sed -i 's|registry.k8s.io/pause:3.8|registry.k8s.io/pause:3.10|g' /etc/containerd/config.toml
        systemctl restart containerd
        systemctl enable --now containerd

        echo "Loading kernel modules..."
        cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
        modprobe overlay
        modprobe br_netfilter

        echo "Enabling IP forwarding..."
        echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-k8s.conf
        cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
        sysctl --system

        echo "Disabling swap..."
        swapoff -a
        sed -i '/swap/d' /etc/fstab

        # Detect architecture and use appropriate CNI plugins
        ARCH=$(uname -m)
        echo "Detected architecture: $ARCH"

        echo "Installing CNI plugins for $ARCH architecture..."
        mkdir -p /opt/cni/bin
        
        if [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
          # ARM64 architecture
          wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-arm64-v1.3.0.tgz -O cni-plugins.tgz
        else
          # Default to AMD64
          wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz -O cni-plugins.tgz
        fi
        
        tar -C /opt/cni/bin -xzf cni-plugins.tgz
        rm -f cni-plugins.tgz

        echo "Installing Kubernetes components..."
        dnf install -y kubeadm kubelet kubectl
        systemctl enable --now kubelet

        echo "Joining Kubernetes cluster..."
        bash /vagrant/k8s-join-command.sh
      SHELL
    end
  end
end
  EOT
}

# Run Vagrant using Terraform
resource "null_resource" "run_vagrant_up" {
  depends_on = [local_file.vagrantfile]

  provisioner "local-exec" {
    command = "vagrant up --provider=vmware_desktop"
  }
}
