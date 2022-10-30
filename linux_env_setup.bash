#!/bin/bash
#Purpose: 
# 1. Hostname Change
# 2. Join domain
# 3. Disable firewall
# 4. Validate Settings
clear
old_hostname="$( hostname )"
echo "Please Enter your Desired Hostname"
echo ""
  read new_hostname

	cat /etc/sysconfig/network | grep NETWORKING > /tmp/hostname.txt
	echo hostname=$new_hostname >> /tmp/hostname.txt
	cat /tmp/hostname.txt > /etc/sysconfig/network

  hostname $new_hostname
  rm -fr /tmp/hostname.txt

if [ -n "$( grep "$old_hostname" /etc/hosts )" ]; then
 sed -i "s/$old_hostname/$new_hostname/g" /etc/hosts
else
 echo -e "$( hostname -I | awk '{ print $1 }' )\t$new_hostname" >> /etc/hosts
fi 

# Domain setup
echo " ++++++++++++++++++++++++"
echo "    Setting up Domain    "
echo ""
echo "Would You Like To Join The New Domain or Leave The Existing Domain"
echo "Enter "J" to Join and "L" to leave"
echo ""
read domain_action
if [ "$domain_action" = "J" ] ||  [ "$domain_action" = "j" ]; then
	echo "Please Enter your Desired Domain"
	read new_domain_name
	echo "Enter the Domain User Name"
	read domain_user_name
	echo "Joining the Domain"
	realm join $new_domain_name -U $domain_user_name
elif [ "$domain_action" = "L" ] || [ "$domain_action" = "l" ]; then
	echo "Please Enter your Existing Domain"
	read existing_domain_name
	echo "Leaving Exiting Domain"
	realm leave $existing_domain_name 
else
	echo "Not A Valid Choice! Exiting"
	exit
fi
echo "Disabling the firewall"
systemctl stop firewalld
sleep 7 
echo ""
echo "++++++++++++++++++++++++"
echo " Validating the Changes "
echo "++++++++++++++++++++++++"
echo "1. NewHost Name is: $new_hostname"
echo ""
echo "2. Checking if the host is part of the Domain"
realm list | grep nextlabs.com
echo ""
echo "3. Checking firewall status"
systemctl status firewalld | head -n4
echo ""
echo "4. Checking Network Status"
systemctl status network | head -n4
echo "IP Address:" 
ip a | grep inet
echo""
echo "5. JAVA Home and Version s:"
which java
java -version
echo ""
echo "6. Network Manager Status is:"
nmcli d
echo "Use "ifup <network-adapter name>" if it is down"
echo ""
echo "7. Data in /etc/hosts is:"
cat /etc/hosts
echo "Good Luck!"
echo ""
#END