# Listen on VLAN subinterfaces only
interface=eth1.100
interface=eth1.101
interface=eth1.805
interface=eth1.850
interface=eth1.1000

# DHCP ranges for each VLAN subnet

# VLAN 100: 10.81.35.128/25  (mask 255.255.255.128)
dhcp-range=eth1.100,10.81.35.130,10.81.35.254,255.255.255.128,12h
dhcp-option=tag:eth1.100,3,10.81.35.129

# VLAN 101: 192.168.161.0/24
dhcp-range=eth1.101,192.168.161.10,192.168.161.254,255.255.255.0,12h
dhcp-option=tag:eth1.101,3,192.168.161.1

# VLAN 805: 192.168.6.0/24
dhcp-range=eth1.805,192.168.6.10,192.168.6.254,255.255.255.0,12h
dhcp-option=tag:eth1.805,3,192.168.6.1

# VLAN 850: 172.18.0.0/21 (255.255.248.0)
dhcp-range=eth1.850,172.18.0.10,172.18.7.254,255.255.248.0,12h
dhcp-option=tag:eth1.850,3,172.18.0.1

# VLAN 1000: 172.20.0.0/20 (255.255.240.0)
dhcp-range=eth1.1000,172.20.0.10,172.20.15.254,255.255.240.0,12h
dhcp-option=tag:eth1.1000,3,172.20.0.1

# DNS servers handed out to clients
dhcp-option=6,8.8.8.8,8.8.4.4
