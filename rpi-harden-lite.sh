#!/bin/bash
# Raspberry Pi (1/2/3) and Raspbian basic hardening tool 
# This tool provides the basic level of security hardening
# for an out-of-box RPi/Raspbian setup . It's meant to 
# provide foundational security measures for most people 
# starting to use Raspberry Pi. More comprehensive hardening
# support is available upon request info@irsols.com
# Open Source software under GPLv3 license. 
echo " IRSOLS IOT Security Hardening Lite Tool"
# Let's do some checks first
if [ -z "$1" ]
   then
	echo "Correct Syntax is : rpi-harden-lite [new_user_name] [new_user_pwd] [new_root_passwd] "
	exit
fi
# Are we root , if not exit now
# This script must be run as root 
if [[ $EUID -ne 0 ]]; then
	   echo "This script must be run as root. perform a sudo su before executiing" 
	   exit 1
fi
export user_name=$1
export user_pswd=$2
export root_pswd=$3
echo " Starting configurations based on security best practices"
echo " This tool will change your system as follows : "
echo " 1. Hostname will be standardized based on last 5 digits of MAC "
echo " 2. Default Pi user will be locked out & new user configured "
echo " 3. root password will be updated " 
echo " 4. Remote access configured based on best practices"
echo "    (Note : sshkey configuration is disabled but  can be turned on later"
echo " 5. Firewall rules are update based on best practices " 
echo " 6. Login messages/banners are enforced & updated " 
# Change the generic hostname to uniquely identifiable 
# hostname based on MAC address & update hosts file so sudo doesnt whine
export mac5=`ip add | grep ether | head -1 | awk {'print $2'} | sed  's/://g' | tail -c 6`
hostnamectl set-hostname "rpi-$mac5"
sed -i s/raspberrypi/$HOSTNAME/g /etc/hosts

# Add the new user first
sudo /usr/sbin/useradd --groups sudo -m $user_name

# Change new replacement user's password
echo "$user_name:$user_pswd" | sudo chpasswd

# Change root password 
echo "root:$root_pswd" | sudo chpasswd
# Keep pi's user profile 
sudo cp -f /home/pi/.bashrc /home/$user_name/.bashrc

# Lockout pi, no need to keep the default user
sudo passwd --lock pi

# Secure SSH : Enable protocol v2 , idle timeout ,
# enforce passwords/auth policies and add banners
# But reconfigure and regenerate the SSH Keys First !!
/bin/rm -v /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server
# Please review the sshd_config to enable/disable key based login
cat strong_ssh.cfg > /etc/ssh/sshd_config
echo "Welcome to rpi-$mac5" > motd
echo "Secured by IRSOLS.COM's IOT hardening lite program" >> motd
echo "System to be accessed by authorized users only,logging enabled" >> motd

cp -f motd /etc/issue.net
cp -f motd /etc/motd

sudo systemctl restart ssh

# Configure the Firewall 
sudo apt-get install iptables iptables-persistent
iptables --flush
# Allow all loopback (lo0) traffic and drop all traffic to 127/8 that doesn't use lo0
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT

# Accepts all established inbound connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allows all outbound traffic
# You could modify this to only allow certain traffic
iptables -A OUTPUT -j ACCEPT

# Allows SSH connections
# The --dport number should match the one in your /etc/ssh/sshd_config
iptables -A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT

# log iptables denied calls (access via 'dmesg' command)
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

# Reject all other inbound - default deny unless explicitly allowed policy:
iptables -A INPUT -j REJECT
iptables -A FORWARD -j REJECT

