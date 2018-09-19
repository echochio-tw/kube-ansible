sed -i 's/#host_key_checking = False/host_key_checking = False/g' /etc/ansible/ansible.cfg
git clone https://github.com/echochio-tw/kube-ansible.git
cd kube-ansible
cat >>inventory/hosts.ini<<EOF
[etcds]
k8s-m[1:2] ansible_user=root

[masters]
k8s-m[1:2] ansible_user=root

[nodes]
k8s-n1 ansible_user=root
k8s-n2 ansible_user=root

[kube-cluster:children]
masters
nodes
EOF

rm -rf inventory/group_vars/all.yml
cat >>inventory/group_vars/all.yml<<EOF
---

kube_version: 1.11.2

# Container runtime,
# Supported: docker, nvidia-docker, containerd.
container_runtime: docker

# Container network,
# Supported: calico, flannel.
cni_enable: true
container_network: calico
cni_iface: "eth1"

# Kubernetes HA extra variables.
vip_interface: "eth1"
vip_address: 192.168.22.180

# etcd extra variables.
etcd_iface: "eth1"

# Kubernetes extra addons
enable_ingress: false
enable_dashboard: true
enable_logging: false
enable_monitoring: true
enable_metric_server: false

grafana_user: "admin"
grafana_password: "p@ssw0rd"
EOF

yum install -y sshpass

rm -rf /root/.ssh
ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N ""
sshpass -p "vagrant" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@k8s-m1
sshpass -p "vagrant" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@k8s-m2
sshpass -p "vagrant" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@k8s-n1
sshpass -p "vagrant" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@k8s-n2
