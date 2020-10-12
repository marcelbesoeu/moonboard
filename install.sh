#!/bin/bash

echo "Make sure spi device enabled in /boot/config.txt"
grep dtparam=spi=on /boot/config.txt 

echo "Make sure to have a good hostname"
sudo hostnamectl set-hostname moonboard

echo "Prepare raspian"
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install git vim python3-pip libatlas-base-dev   

echo "Install application"
test -d moonboard || git clone https://github.com/travismartinjones/moonboard.git
cd moonboard
git pull
pip3 install -r requirements.txt
pip3 install spidev python-periphery

echo "Install service"
cd services
sudo ./install_service.sh moonboard.service 
cd ..

echo "Enable SPI"
sudo sed -i 's/\#dtparam=spi=on/dtparam=spi=on/g' /boot/config.txt

#echo "Start advertising stuff"
#sudo hcitool -i hci0 cmd 0x08 0x0008 {adv: 32 byte 0-padded if necessary}
#sudo hcitool -i hci0 cmd 0x08 0x0009 {adv: 32 byte 0-padded if necessary}
#sudo hcitool -i hci0 cmd 0x08 0x0006 {min:2byte} {max:2byte} {connectable:1byte} 00 00 00 00 00 00 00 00 07 00
#sudo hcitool -i hci0 cmd 0x08 0x000a 01

echo "Prepare logfiles"
sudo touch /var/log/moonboard
sudo chown pi:pi /var/log/moonboard

#python3 ./run.py --driver SimPixel --debug

# Prepare phase 2 to run at boot
sudo sed -i 's/exit 0/sudo \/home\/pi\/moonboard\/install-phase2.sh\r\nexit 0/g' /etc/rc.local

echo "Restarting in 5 seconds to finalize changes. CTRL+C to cancel."
sleep 1 > /dev/null
printf "."
sleep 1 > /dev/null
printf "."
sleep 1 > /dev/null
printf "."
sleep 1 > /dev/null
printf "."
sleep 1 > /dev/null
printf " Restarting"
sudo shutdown -r now
