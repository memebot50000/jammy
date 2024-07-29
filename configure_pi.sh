#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Get the current script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Step 1: Ensure WiFi Connection on Startup

# Create a systemd service to ensure WiFi connection
cat > /etc/systemd/system/wifi-connect.service << EOF
[Unit]
Description=Ensure WiFi connection on startup
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/nmcli device wifi connect 'Your_SSID' password 'Your_Password'

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
systemctl enable wifi-connect.service

# Step 2: Disable Login Screen and Enable Auto-Login

# Install LightDM if not already installed
apt update
apt install -y lightdm

# Configure LightDM for auto-login
cat > /etc/lightdm/lightdm.conf << EOF
[Seat:*]
autologin-user=deltav
autologin-user-timeout=0
user-session=ubuntu
EOF

# Step 3: Run setup_hotspot.sh on Startup

# Create a systemd service to run setup_hotspot.sh on startup
cat > /etc/systemd/system/setup-hotspot.service << EOF
[Unit]
Description=Run setup_hotspot.sh on startup
After=network.target

[Service]
Type=oneshot
ExecStart=${SCRIPT_DIR}/setup_hotspot.sh

[Install]
WantedBy=multi-user.target
EOF

# Make setup_hotspot.sh executable
chmod +x ${SCRIPT_DIR}/setup_hotspot.sh

# Enable the service
systemctl enable setup-hotspot.service

# Update the wifi-connect.service with your actual WiFi credentials
sed -i "s/Your_SSID/Your_SSID/g" /etc/systemd/system/wifi-connect.service
sed -i "s/Your_Password/1234/g" /etc/systemd/system/wifi-connect.service

echo "Configuration complete. Please reboot your Raspberry Pi."
