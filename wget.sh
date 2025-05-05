#!/bin/sh



#To be added --> Check if services.xml exists and use it at boot
#To be added --> PAN vlans templates for manual setup
#To be added --> USB/emmc management to mount and search for backup
#To be added --> If backup isn't available save to USB/emmc for reboot persistence
#To be added --> a way to push agent ssh keys so they can access equipment behind the bypassed gw
#To be added --> some sort of monitoring GUI (accessible via ssh tunnel) so agents can get equipment status


echo "============================================================"
echo " TinyCore Gateway bypass Provisioning Script"
echo "============================================================"
echo ""
echo "This script helps assist you to provision the bypass of the gateway"
echo "during the boot process. A few questions will be asked in order to"
echo "configure the bypass. The script will then proceed to set up the"
echo "necessary network routing and configurations for the bypass."
echo ""
echo "If you prefer to configure this manually or need to modify any settings,"
echo "simply press Ctrl-C to cancel the automatic setup. Otherwise, answer"
echo "the prompts below to proceed with the assisted provisioning."
echo ""
echo "The script will ensure the bypass is configured easily, but manual"
echo "intervention is always available if needed."
echo ""
echo "============================================================"

#ensure proper software is available and usable 
echo " For now please make sure to run the following before running "
echo "tce-load -wi bash openssh dnsmasq ipset net-tools iperf3 tcpdump wget"
echo "to ensure you have all required software"



# Bring all interfaces down initially to prevent dhcp from admin port
# before the WAN is properly setup
echo "Bringing interfaces down to define interface roles, only WAN and LAN roles are supported other interfaces like ADMIN and OPT will be disabled !!!"
for iface in $(ls /sys/class/net); do
    sudo ifconfig $iface down
done
echo
echo
echo
# List available interface name and MAC so user knows each interface MAC to map the right 

echo "Identify WAN and LAN interface names using MAC address from the list below: "
echo
echo

for iface in $(ls /sys/class/net); do
    echo -n "$iface: "
    cat /sys/class/net/$iface/address
done

# Prompt the user for WAN and LAN interfaces
echo "Please enter the interface for WAN (e.g., eth0):"
read WAN_IFACE

echo "Please enter the interface for LAN (e.g., eth1):"
read LAN_IFACE

# Ask if WAN should use DHCP or Static IP
echo "Should the WAN interface use DHCP? (y/n)"
read WAN_DHCP

ifconfig $LAN_IFACE up

if [ "$WAN_DHCP" = "y" ]; then
    # Configure the WAN interface with DHCP
    echo "Configuring $WAN_IFACE as WAN with DHCP..."
    sudo ifconfig $WAN_IFACE up
    sudo dhclient $WAN_IFACE
else
    # Gather static IP, subnet mask, and gateway for WAN interface
    echo "Please enter the static IP address for $WAN_IFACE (e.g., 172.16.10.2):"
    read WAN_IP

    echo "Please enter the subnet mask for $WAN_IFACE (e.g., 255.255.255.0):"
    read WAN_SUBNET

    echo "Please enter the default gateway for $WAN_IFACE (e.g., 172.16.10.1):"
    read WAN_GW

    # Configure the WAN interface with static IP
    echo "Configuring $WAN_IFACE with static IP $WAN_IP..."
    sudo ifconfig $WAN_IFACE $WAN_IP netmask $WAN_SUBNET up

    # Set the default gateway
    sudo route add default gw $WAN_GW $WAN_IFACE
fi

# Configure the LAN interface with a static IP
echo "Configuring $LAN_IFACE as LAN with static IP..."
echo "interface/subnet br0/VLAN 1"
sudo ifconfig $LAN_IFACE 172.16.48.1 netmask 255.255.240.0 up
sudo ifconfig $LAN_IFACE:1 10.57.169.1 netmask 255.255.255.0 up


######################################################################
#Creating Client VLANS
echo "Configuring base Client VLANS"

sudo vconfig add $LAN_IFACE 100
sudo ifconfig $LAN_IFACE.100 10.81.35.129 netmask 255.255.255.128 up
sudo vconfig add $LAN_IFACE 101
sudo ifconfig $LAN_IFACE.101 192.168.161.1 netmask 255.255.255.0 up
sudo vconfig add $LAN_IFACE 805
sudo ifconfig $LAN_IFACE.805 192.168.6.1 netmask 255.255.255.0 up
sudo vconfig add $LAN_IFACE 850
sudo ifconfig $LAN_IFACE.850 172.18.0.1 netmask 255.255.0.0 up
sudo vconfig add $LAN_IFACE 1000
sudo ifconfig $LAN_IFACE.1000 172.20.0.1 netmask 255.255.240.0 up
sudo vconfig add $LAN_IFACE 1016
sudo ifconfig $LAN_IFACE.1016 172.20.16.1 netmask 255.255.255.0 up
sudo vconfig add $LAN_IFACE 1017
sudo ifconfig $LAN_IFACE.1017 172.20.17.1 netmask 255.255.255.0 up
sudo vconfig add $LAN_IFACE 1018
sudo ifconfig $LAN_IFACE.1018 172.20.18.1 netmask 255.255.255.0 up
sudo vconfig add $LAN_IFACE 1025
sudo ifconfig $LAN_IFACE.1025 172.25.0.1 netmask 255.255.0.0 up
sudo vconfig add $LAN_IFACE 1050
sudo ifconfig $LAN_IFACE.1050 172.20.50.1 netmask 255.255.255.0 up

echo "Base Client VLANS created"
######################################################################

#Conference VLANS

# Ask the user a yes/no question
echo "Do you want to add Conference VLANs? (yes/no)"
read answer

# Check if the answer is "yes" (case-insensitive)
if [[ "$answer" =~ ^[Yy](es)?$ ]]; then


# VLAN to IP mapping
VLAN_IPS="\
1026 172.26.0.1 netmask 255.255.0.0
1027 172.27.0.1 netmask 255.255.0.0
1028 172.28.0.1 netmask 255.255.240.0
1029 172.28.16.1 netmask 255.255.240.0
1030 172.28.32.1 netmask 255.255.240.0
1031 172.28.48.1 netmask 255.255.240.0
1032 172.28.64.1 netmask 255.255.240.0
1033 172.28.80.1 netmask 255.255.240.0
1034 172.28.96.1 netmask 255.255.240.0
1035 172.28.112.1 netmask 255.255.240.0
1036 172.28.128.1 netmask 255.255.240.0
1037 172.28.144.1 netmask 255.255.240.0
1038 172.28.160.1 netmask 255.255.240.0
1039 172.28.176.1 netmask 255.255.240.0
1040 172.28.192.1 netmask 255.255.240.0
1041 172.28.208.1 netmask 255.255.240.0
1042 172.28.224.1 netmask 255.255.240.0
1043 172.29.0.1 netmask 255.255.240.0
1044 172.29.16.1 netmask 255.255.240.0
1045 172.29.32.1 netmask 255.255.240.0
1046 172.29.48.1 netmask 255.255.240.0
1047 172.29.64.1 netmask 255.255.240.0
1048 172.29.80.1 netmask 255.255.240.0
1049 172.29.96.1 netmask 255.255.240.0
"

echo "$VLAN_IPS" | while read VLAN IPADDR NETMASK; do
  IFACE="$LAN_IFACE.$VLAN"
  sudo vconfig add "$LAN_IFACE" "$VLAN"
  sudo ifconfig "$IFACE" "$IPADDR" $NETMASK up
done

else
    echo "Skipping Conference VLANs setup."
fi

# Set up NAT between WAN_IFACE and LAN_IFACE using ipset
echo "Setting up NAT (masquerading) between $WAN_IFACE and $LAN_IFACE..."

# Ensure iptables and ipset are available
modprobe ip_tables
modprobe iptable_nat
modprobe ip_set

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Set up NAT (MASQUERADE) to allow internet access for LAN
sudo iptables -t nat -A POSTROUTING -o $WAN_IFACE -j MASQUERADE

# Optionally, set up firewall rules to allow traffic
sudo iptables -A FORWARD -i $WAN_IFACE -o $LAN_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $LAN_IFACE -o $WAN_IFACE -j ACCEPT

# Optional: Set up DNS for WAN
echo "Configuring DNS for WAN..."
echo "nameserver 8.8.8.8" > /etc/resolv.conf

echo "Network setup [in]complete [because this is a test run]."

