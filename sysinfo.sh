#!/bin/sh

if ! [ $(id -u) = 0 ]; then
   echo "Generator sysinfo for privileged user only" >&2
   exit 1
fi

# variable

clear
echo "Generating sysinfo"

cat << EOF > /tmp/sysinfo.md

# System Information

## Machine

\`\`\`
      Manufacturer: $(cat /sys/class/dmi/id/sys_vendor)
             Model: $(cat /sys/class/dmi/id/product_name)
$(hostnamectl status)
  Operating System: $(cat /etc/*-release | grep DISTRIB_DESCRIPTION | sed s/DISTRIB_DESCRIPTION=\"// | sed s/\"//)
\`\`\`

---

## Hardware Information

\`\`\`
$(lshw -short)
\`\`\`

###### Processor

\`\`\`
$(lscpu)
\`\`\`

###### Memory

\`\`\`
$(lsmem)
\`\`\`

###### Network

\`\`\`
$(ifconfig -a)
\`\`\`

###### PCI

\`\`\`
$(lspci -kv)
\`\`\`

###### USB

\`\`\`
$(lsusb)
\`\`\`

###### SMBIOS

\`\`\`
$(dmidecode -q)
\`\`\`

---

## Network and Security Information

#### Networking

###### Nameservers

\`\`\`
$(cat /etc/resolv.conf)
\`\`\`

###### Active Internet Connections

\`\`\`
$(netstat -tulpn)
\`\`\`

###### Connect Internet Connections

\`\`\`
$(lsof -i)
\`\`\`

#### Firewall

###### ufw

\`\`\`
$(sudo ufw status verbose)
\`\`\`

###### iptable

\`\`\`
$(iptables -L -n)
\`\`\`

---

## System Infomation

#### Kernel

\`\`\`
$(uname -a)
\`\`\`

###### Kernel Modules :

\`\`\`
$(lsmod)
\`\`\`

###### Kernel Parameter

\`\`\`
$(sysctl -a)
\`\`\`

#### BOOT

\`\`\`
$(cat /proc/cmdline)
\`\`\`

####### Bootloader (GRUB2)

\`\`\`
$(cat /boot/grub2/grub.cfg)
\`\`\`

####### System Services (systemd)

Total   : **$(systemctl --no-legend | wc -l)**

\`\`\`
$(systemctl --no-page --no-legend)
\`\`\`

---

## Software Information

###### Repository

\`\`\`
$(apt-cache policy| grep http | awk '{print $2 " " $3}')
\`\`\`

###### Installed Packages - APT

Total   : **$(apt list --installed 2>/dev/null | wc -l)**

\`\`\`
$(apt list --installed 2>/dev/null)
\`\`\`

###### Installed Packages - DPKG

Total   : **$(dpkg-query -l | nl | tail -1 | awk '{print $1}')**

\`\`\`
$(dpkg --list)
\`\`\`

---

Report Generated
Date    : $(date +%d-%m-%Y" "%H:%M:%S" UTC"%Z)
EOF

cp /tmp/sysinfo.md ./sysinfo.md
rm -rf /tmp/sysinfo.md

echo
echo "Sysinfo report are generated" 
echo "FILES : $(pwd)/sysinfo.md"
