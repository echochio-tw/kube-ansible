yum -y install haproxy keepalived
rm -rf /etc/haproxy/haproxy.cfg
cat << 'EOF' >> /etc/haproxy/haproxy.cfg
global
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  tune.ssl.default-dh-param 2048

defaults
  log global
  mode http
  option dontlognull
  timeout connect 5000ms
  timeout client 1800000ms
  timeout server 1800000ms

listen stats
    bind :9090
    mode http
    balance
    stats uri /haproxy_stats
    stats auth admin:admin123
    stats admin if TRUE

frontend kube-apiserver-https
   mode tcp
   bind :8443
   default_backend kube-apiserver-backend

backend kube-apiserver-backend
    mode tcp
    server kube-apiserver1 k8s-m1:6443 check
    server kube-apiserver2 k8s-m2:6443 check
EOF

rm -rf /etc/keepalived/keepalived.conf
cat << 'EOF' >> /etc/keepalived/keepalived.conf
vrrp_script chk_haproxy {
    script "systemctl is-active haproxy"
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth1
    virtual_router_id 1
    priority 100
    virtual_ipaddress {
        192.168.22.180
    }
    track_script {
        chk_haproxy
    }
}
EOF
systemctl enable haproxy
systemctl enable keepalived
systemctl start haproxy
systemctl start keepalived