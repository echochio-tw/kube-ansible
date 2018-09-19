cat << 'EOF' >> /etc/hosts
192.168.22.164 master1 k8s-m1
192.168.22.165 master2 k8s-m2
192.168.22.166 node1 k8s-n1
192.168.22.167 node2 k8s-n2
192.168.22.180 master k8s-m
EOF
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
yum -y update
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux