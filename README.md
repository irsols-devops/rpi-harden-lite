 IRSOLS.COM IOT Security Tools Set
 Raspberry Pi (1/2/3) and Raspbian basic hardening tool 
 This tool provides the basic level of security hardening
 for an out-of-box RPi/Raspbian setup . It's meant to 
 provide foundational security measures for most people 
 starting to use Raspberry Pi. More comprehensive hardening
 support is available upon request info@irsols.com
 Open Source software under GPLv3 license. 
 
 This tool will change your RPi system based on Security 
 Best Practices as follows: 

 1. Hostname will be standardized based on last 5 digits of MAC
 2. Default Pi user will be locked out & a new user configured
 3. root password will be updated 
 4. Remote access configured based on best practices
    (Note : sshkey configuration is disabled but  can be 
    turned on later )
 5. Firewall rules are updated based on best practices 
 6. Login messages/banners are enforced & updated 

Quick start : 1. git clone https://github.com/irsols-devops/rpi-harden-lite.git
	      2. cd rpi-harden-lite
  	      3. sudo su
     	      4. ./rpi-harden-lite.sh [NewUserName] [NewUserPasswd] [NewRootPasswd]
              5. Hit Yes to any pop up dialogs 
 	      6. reboot / logout and log back in with your new user/passwd

