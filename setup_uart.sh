#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Enable UART in /boot/firmware/config.txt
CONFIG_FILE="/boot/firmware/config.txt"
if ! grep -q "enable_uart=1" "$CONFIG_FILE"; then
    echo "enable_uart=1" | sudo tee -a "$CONFIG_FILE"
fi
if ! grep -q "dtoverlay=disable-bt" "$CONFIG_FILE"; then
    echo "dtoverlay=disable-bt" | sudo tee -a "$CONFIG_FILE"
fi

# Disable serial console in /boot/firmware/cmdline.txt
CMDLINE_FILE="/boot/firmware/cmdline.txt"
sudo sed -i 's/console=serial0,115200 //' "$CMDLINE_FILE"

# Reboot the system to apply changes
echo "Rebooting the system to apply changes..."
sudo reboot

# Wait for the system to reboot
sleep 60

# Install pyserial if not already installed
sudo apt-get install -y python3-serial

# Create the Python script to send data through TXD pin
PYTHON_SCRIPT="/home/$USER/uart_test.py"
cat << 'EOF' > "$PYTHON_SCRIPT"
import serial
import time

# Open the serial port (adjust the port name if necessary)
ser = serial.Serial('/dev/ttyAMA0', 115200, timeout=1)

while True:
    # Send data through the TXD pin
    ser.write(b'UART Test\n')
    print("Data sent: UART Test")
    time.sleep(1)
EOF

# Make the Python script executable
chmod +x "$PYTHON_SCRIPT"

# Print instructions to run the Python script
echo "Setup complete. To run the Python script, execute the following command:"
echo "python3 $PYTHON_SCRIPT"
