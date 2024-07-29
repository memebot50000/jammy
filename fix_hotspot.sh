#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Install necessary packages
apt update
apt install -y hostapd dnsmasq network-manager

# Stop services
systemctl stop hostapd
systemctl stop dnsmasq

# Configure hostapd
cat > /etc/hostapd/hostapd.conf << EOF
interface=wlan0
driver=nl80211
ssid=DeltaV
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=1234
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

# Configure dnsmasq
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
cat > /etc/dnsmasq.conf << EOF
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
EOF

# Configure network interfaces using NetworkManager
nmcli radio wifi on
nmcli dev wifi hotspot ifname wlan0 con-name DeltaV ssid DeltaV password "1234"

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Configure NAT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

# Save iptables rules
iptables-save > /etc/iptables.ipv4.nat

# Create startup script
cat > /usr/local/bin/start_hotspot.sh << EOF
#!/bin/bash
iptables-restore < /etc/iptables.ipv4.nat
nmcli con up DeltaV
EOF

chmod +x /usr/local/bin/start_hotspot.sh

# Create systemd service
cat > /etc/systemd/system/hotspot.service << EOF
[Unit]
Description=WiFi hotspot
After=network.target

[Service]
ExecStart=/usr/local/bin/start_hotspot.sh

[Install]
WantedBy=multi-user.target
EOF

# Enable services
systemctl enable NetworkManager
systemctl enable hotspot.service

# Start services
systemctl start NetworkManager
systemctl start hotspot.service

# Fix permissions for netplan files
chmod 600 /etc/netplan/*.yaml

echo "WiFi hotspot setup complete. Please reboot your Raspberry Pi."
