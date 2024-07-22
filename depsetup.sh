#!/bin/bash
echo "Cloning PX4 repo"
cd ~/
git clone https://github.com/PX4/PX4-Autopilot.git --recursive
echo "Setting up PX4"
bash ./PX4-Autopilot/Tools/setup/ubuntu.sh
echo "Installing Python dependencies"
pip install jupyterlab==4.1.7
pip install lark
pip3 install --user -U empy==3.3.4 pyros-genmsg setuptools
pip3 install kconfiglib
pip install --user jsonschema
pip install --user jinja2
echo "Cloning DDS repo"
git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git
cd Micro-XRCE-DDS-Agent
mkdir build
cd build
cmake ..
make
sudo make install
sudo ldconfig /usr/local/lib/
echo "Micro XRCE DDS installed"
echo "Setting up ROS workspace"
mkdir -p ~/ros2_uav_ws/src
cd ~/ros2_uav_ws/src
git clone https://github.com/PX4/px4_msgs.git
git clone https://github.com/ARK-Electronics/ROS2_PX4_Offboard_Example.git
source /opt/ros/humble/setup.bash
cd ..
colcon build 
source install/setup.bash
echo "Rebooting for changes to take effect, please enter your password when prompted"
sudo reboot
