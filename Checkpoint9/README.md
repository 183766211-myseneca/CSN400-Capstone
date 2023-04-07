# Checkpoint9 Submission

- **COURSE INFORMATION: CSN400NAA**
- **STUDENT’S NAME: Evan Scheller**
- **STUDENT'S NUMBER: 183766211**
- **GITHUB USER ID: 183766211-myseneca**
- **TEACHER’S NAME: Atoosa Nasiri**

### Table of Contents

1. [Part A - Route Table Updates](#part-a---route-table-updates)
2. [Part B - Port Forwarding Basic Connectivity](#part-b---port-forwarding-basic-connectivity)
3. [Part C - Logging and Isolating Masqueraded Packets](#part-c---logging-and-isolating-masqueraded-packets)
4. [Part D - Azure Cost Analysis Charts](#part-d---azure-cost-analysis-charts)

## Part A - Route Table Updates
Route tables: `az network route-table list -o table`
```
DisableBgpRoutePropagation    Location       Name      ProvisioningState    ResourceGroup      ResourceGuid
----------------------------  -------------  --------  -------------------  -----------------  ------------------------------------
True                          canadacentral  RT-32     Succeeded            Student-RG-846011  2e1554ad-685c-4f84-bccd-75e54ca3a592
False                         canadacentral  RT-EX-32  Succeeded            Student-RG-846011  0fb1ce35-b760-49b5-9487-72f5deb2ff21
```
### RT-EX-32 
Route 'Route-to-Hub': `az network route-table route show -g Student-RG-846011 --route-table-name RT-EX-32 -n Route-to-Hub -o table`

```
AddressPrefix     HasBgpOverride    Name          NextHopIpAddress    NextHopType       ProvisioningState    ResourceGroup
----------------  ----------------  ------------  ------------------  ----------------  -------------------  -----------------
192.168.39.32/27  False             Route-to-Hub  192.168.99.36       VirtualAppliance  Succeeded            Student-RG-846011
```
Associated subnet: `az network vnet subnet show -g Student-RG-846011 -n SN1 --vnet-name Server-32 -o table`
```
AddressPrefix    Name    PrivateEndpointNetworkPolicies    PrivateLinkServiceNetworkPolicies    ProvisioningState    ResourceGroup
---------------  ------  --------------------------------  -----------------------------------  -------------------  -----------------
172.17.32.32/27  SN1     Disabled                          Enabled                              Succeeded            Student-RG-846011
```

### RT-32 
Route 'External-Router': `az network route-table route show -g Student-RG-846011 --route-table-name RT-32 -n External-Router -o table`
```
AddressPrefix     HasBgpOverride    Name             NextHopIpAddress    NextHopType       ProvisioningState    ResourceGroup
----------------  ----------------  ---------------  ------------------  ----------------  -------------------  -----------------
192.168.39.32/27  False             External-Router  192.168.32.36       VirtualAppliance  Succeeded            Student-RG-846011
```
Associated subnet: `az network vnet subnet show -g Student-RG-846011 -n SN1 --vnet-name Router-32 -o table`
```
AddressPrefix    Name    PrivateEndpointNetworkPolicies    PrivateLinkServiceNetworkPolicies    ProvisioningState    ResourceGroup
---------------  ------  --------------------------------  -----------------------------------  -------------------  -----------------
172.17.32.32/27  SN1     Disabled                          Enabled                              Succeeded            Student-RG-846011
```

## Part B - Port Forwarding Basic Connectivity
nat_basic_connectivity.sh
```
# to flush NAT tables
iptables -t nat -F

#LOGGING
iptables -t nat -A PREROUTING -p tcp --dport 1832 -j LOG --log-prefix "Prerouting Apache"
# to allow other students to access APACHE server
iptables -t nat -A PREROUTING -p tcp --dport 1832 -j DNAT --to-destination 172.17.32.37:80

#LOGGING
iptables -t nat -A PREROUTING -p tcp --dport 1632 -j LOG --log-prefix "Prerouting MySQL"
# to allow other students to access MySQL server
iptables -t nat -A PREROUTING -p tcp --dport 1632 -j DNAT --to-destination 172.17.32.37:3306

#LOGGING
iptables -t nat -A PREROUTING -p tcp --dport 1232 -j LOG --log-prefix "Prerouting SSH"
# to allow other students to access Linux server - SSH
iptables -t nat -A PREROUTING -p tcp --dport 1232 -j DNAT --to-destination 172.17.32.37:22

#LOGGING
iptables -t nat -A PREROUTING -p tcp --dport 1932 -j LOG --log-prefix "Prerouting IIS"
# to allow other students to access IIS server
iptables -t nat -A PREROUTING -p tcp --dport 1932 -j DNAT --to-destination 172.17.32.36:80

#LOGGING
iptables -t nat -A PREROUTING -p tcp --dport 1332 -j LOG --log-prefix "Prerouting RDP"
# to allow other students to access Windows server - RDP
iptables -t nat -A PREROUTING -p tcp --dport 1332 -j DNAT --to-destination 172.17.32.36:3389

#POSTROUTING
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

firewalls-cp9.sh
```
echo "-------------------------------------------"
echo "Flush All Iptables Chains/Firewall rules"
iptables -F

# Delete all Iptables Chains
echo "-------------------------------------------"
echo "Delete all Iptables Chains"
iptables -X

#Logging all
#iptables -A FORWARD -p any -d 10.52.19.0/24 -s 192.168.39.36 -m limit --limit 10/sec -j LOG --log-prefix "log-captures-masquerading"

# allow custom port for partner Apache Server
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 192.168.39.36 --sport 1839 -m limit --limit 10/sec -j LOG --log-prefix "log-captures-custom-apache"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 192.168.39.36 --dport 1839 -j ACCEPT
iptables -A FORWARD -p tcp -s 192.168.39.36 -d 10.52.19.0/24 --sport 1839 -j ACCEPT

# allow custom port for partner MySQL Server
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 192.168.39.36 --sport 1639 -m limit --limit 10/sec -j LOG --log-prefix "log-captures-custom-mysql"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 192.168.39.36 --dport 1639 -j ACCEPT
iptables -A FORWARD -p tcp -s 192.168.39.36 -d 10.52.19.0/24 --sport 1639 -j ACCEPT

# allow custom port for partner IIS Server
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 192.168.39.36 --sport 1939 -m limit --limit 10/sec -j LOG --log-prefix "log-captures-custom-iis"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 192.168.39.36 --dport 1939 -j ACCEPT
iptables -A FORWARD -p tcp -s 192.168.39.36 -d 10.52.19.0/24 --sport 1939 -j ACCEPT

# allow custom port for partner Windows Server RDP
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 192.168.39.36 --sport 1339 -m limit --limit 10/sec -j LOG --log-prefix "log-captures-custom-rdp"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 192.168.39.36 --dport 1339 -j ACCEPT
iptables -A FORWARD -p tcp -s 192.168.39.36 -d 10.52.19.9/24 --sport 1339 -j ACCEPT

# allow custom port88?? for partner Linux Server SSH
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 192.168.39.36 --sport 1239 -m limit --limit 10/sec -j LOG --log-prefix "log-captures-custom-ssh"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 192.168.39.36 --dport 1239 -j ACCEPT
iptables -A FORWARD -p tcp -s 192.168.39.36 -d 10.52.19.0/24 --sport 1239 -j ACCEPT

# allow partner traffic after NAT mapping
#HTTP
iptables -A FORWARD -p tcp -s 192.168.39.36 --dport 80 -m limit --limit 10/sec -j LOG --log-prefix "log-captures-masquerading-http"
iptables -A FORWARD -p tcp -s 192.168.39.36 --dport 80 -j ACCEPT
iptables -A FORWARD -p tcp -d 192.168.39.36 --sport 80 -j ACCEPT
# SSH
iptables -A FORWARD -p tcp -s 192.168.39.36 --dport 22 -m limit --limit 10/sec -j LOG --log-prefix "log-captures-masquerading-ssh"
iptables -A FORWARD -p tcp -s 192.168.39.36 --dport 22 -j ACCEPT
iptables -A FORWARD -p tcp -d 192.168.39.36 --sport 22 -j ACCEPT
# RDP
iptables -A FORWARD -p tcp -s 192.168.39.36 --dport 3389 -m limit --limit 10/sec -j LOG --log-prefix "log-captures-masquerading-rdp"
iptables -A FORWARD -p tcp -s 192.168.39.36 --dport 3389 -j ACCEPT
iptables -A FORWARD -p tcp -d 192.168.39.36 --sport 3389 -j ACCEPT
#MySQL
iptables -A FORWARD -p tcp -s 192.168.39.36 --dport 3306 -m limit --limit 10/sec -j LOG --log-prefix "log-captures-masquerading-mysql"
iptables -A FORWARD -p tcp -s 192.168.39.36 --dport 3306 -j ACCEPT
iptables -A FORWARD -p tcp -d 192.168.39.36 --sport 3306 -j ACCEPT




# LOGGING
iptables -A INPUT -p tcp -s 10.52.19.0/24 -d 192.168.32.36 --dport 22 -m limit --limit 10/sec -j LOG --log-prefix "SSH INPUT LR-32 - "
iptables -A INPUT -p tcp -s 10.52.19.0/24 -m state --state NEW --dport 22 -m limit --limit 10/sec -j LOG --log-prefix "SSH NEW TO LR-32 - "
# Allow any INPUT tcp traffic if RELATED or ESTABLISHED
echo "-------------------------------------------"
echo "Allow any INPUT tcp traffic if RELATED or ESTABLISHED"
iptables -A INPUT -p tcp -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow icmp traffic into the VM
echo "-------------------------------------------"
echo "Allow icmp traffic into the VM"
iptables -A INPUT -p icmp -s 10.52.19.0/24 -d 192.168.32.36 -j ACCEPT
iptables -A INPUT -p icmp -s 192.168.39.36 -d 192.168.32.36 -j ACCEPT
iptables -A INPUT -p icmp -s 192.168.99.36 -d 192.168.32.36 -j ACCEPT

# Allow any traffic from loopback interface into the VM
echo "-------------------------------------------"
echo "Allow any traffic from loopback interface into the VM"
iptables -A INPUT -i lo -j ACCEPT

# Allow all SSH traffic on port 22 from Source IP subnet student_vnet
echo "-------------------------------------------"
echo "Allow all SSH traffic on port 22 from Source IP subnet student_vnet"
iptables -A INPUT -p tcp -s 10.52.19.0/24 -m state --state NEW --dport 22 -j ACCEPT

# Log before DROPPING
echo "-------------------------------------------"
echo "Add a rule to LOG instead of DROPPING INPUT packets"
iptables -A INPUT -p all -m limit --limit 10/s -j LOG  --log-prefix "TO_DROP_INPUT"

# Reject all other INPUT traffic
# echo "-------------------------------------------"
# echo "Reject all other INPUT traffic"
iptables -A INPUT -j DROP

# Allow forwarding SSH traffic on port 22 from Windows Client to Server SN1
echo "-------------------------------------------"
echo "SSH"
echo "Allow forwarding all SSH traffic on port 22 from any source to any destination"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.37 --dport 22 -m limit --limit 10/sec -j LOG --log-prefix "SSH FORWARD TO LS-32 - "
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 172.17.32.37 --sport 22 -m limit --limit 10/sec -j LOG --log-prefix "SSH FORWARD FROM LS-32 - "
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.32/27 --dport 22 -j ACCEPT
iptables -A FORWARD -p tcp -s 172.17.32.32/27 -d 10.52.19.0/24 --sport 22 -j ACCEPT


# Allow forwarding RDP traffic on port 3389 from from Windows Client to Server SN1
echo "-------------------------------------------"
echo "RDP"
echo "Allow forwarding all RDP traffic on port 3389 from any source to any destination"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.36 --dport 3389 -m limit --limit 10/sec -j LOG --log-prefix "RDP FORWARD TO WS-32 - "
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 172.17.32.36 --sport 3389 -m limit --limit 10/sec -j LOG --log-prefix "RDP FORWARD FROM WS-32 - "
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.32/27 --dport 3389 -j ACCEPT
iptables -A FORWARD -p tcp -s 172.17.32.32/27 -d 10.52.19.0/24 --sport 3389 -j ACCEPT

# DNS Rules
echo "-------------------------------------------"
echo "DNS"
echo "Logging rules"
iptables -A FORWARD -p tcp -d 172.17.32.36 --dport 53 -m limit --limit 10/sec -j LOG --log-prefix "DNS TCP FORWARD TO WS-32 - "
iptables -A FORWARD -p tcp -s 172.17.32.36 --sport 53 -m limit --limit 10/sec -j LOG --log-prefix "DNS TCP FORWARD FROM WS-32 - "
iptables -A FORWARD -p udp -d 172.17.32.36 --dport 53 -m limit --limit 10/sec -j LOG --log-prefix "DNS UDP FORWARD TO WS-32 - "
iptables -A FORWARD -p udp -s 172.17.32.36 --sport 53 -m limit --limit 10/sec -j LOG --log-prefix "DNS UDP FORWARD FROM WS-32 - "

echo "allow any tcp and udp traffic pass through Linux router for DNS protocol"
iptables -A FORWARD -p tcp -d 172.17.32.36 --dport 53 -j ACCEPT
iptables -A FORWARD -p tcp -s 172.17.32.36 --sport 53 -j ACCEPT
iptables -A FORWARD -p udp -d 172.17.32.36 --dport 53 -j ACCEPT
iptables -A FORWARD -p udp -s 172.17.32.36 --sport 53 -j ACCEPT

# MySQL rules
echo "-------------------------------------------"
echo "MySQL"
echo "Logging rules"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.37 --dport 3306 -m limit --limit 10/sec -j LOG --log-prefix "MySQL FORWARD TO LS-32 - "
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 172.17.32.37 --sport 3306 -m limit --limit 10/sec -j LOG --log-prefix "MySQL FORWARD FROM LS-32 - "
echo "allow any tcp traffic pass through Source WC-xx subnet to Destination LS-xx for destination MySQL protocol"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.37 --dport 3306 -j ACCEPT
echo "allow any tcp traffic pass through Source WS-xx to destination WC-xx subnet for source MySQL protocol"
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 172.17.32.37 --sport 3306 -j ACCEPT

# Apache HTTP rules
echo "-------------------------------------------"
echo "Apache"
echo "Logging rules"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.37 --dport 80 -m limit --limit 10/sec -j LOG --log-prefix "HTTP FORWARD TO LS-32 - "
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 172.17.32.37 --sport 80 -m limit --limit 10/sec -j LOG --log-prefix "HTTP FORWARD FROM LS-32 - "
echo "allow any tcp traffic pass through Source WC-xx subnet to Destination WS-xx for destination Apache protocol"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.37 --dport 80 -j ACCEPT
echo "allow any tcp traffic pass through Source WS-xx to destination WC-xx subnet for source Apache protocol"
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 172.17.32.37 --sport 80 -j ACCEPT


# IIS rules
echo "-------------------------------------------"
echo "IIS"
echo "Logging rules"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.36 --dport 80 -m limit --limit 10/sec -j LOG --log-prefix "HTTP FORWARD TO WS-32 - "
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 172.17.32.36 --sport 80 -m limit --limit 10/sec -j LOG --log-prefix "HTTP FORWARD FROM WS-32 - "
echo "allow any tcp traffic pass through Source WC-xx subnet to Destination LR-xx for destination HTTP protocol to access IIS"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.36 --dport 80 -j ACCEPT
echo "allow any tcp traffic pass through Source LS-xx to destination WC-xx subnet for source HTTP protocol to access IIS"
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 172.17.32.36 --sport 80 -j ACCEPT

# FTP Control rules
echo "-------------------------------------------"
echo "FTP Administration Port"
echo "Logging rules"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.36 --dport 21 -m limit --limit 10/sec -j LOG --log-prefix "FTP CONTROL PLANE FORWARD TO WS-32 - "
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 172.17.32.36 --sport 21 -m limit --limit 10/sec -j LOG --log-prefix "FTP CONTROL PLANE FORWARD FROM WS-32 - "
echo "allow any tcp traffic pass through Source WC-xx subnet to Destination LR-xx for destination FTP protocol"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.36 --dport 21 -j ACCEPT
echo "allow any tcp traffic pass through Source LS-xx to destination WC-xx subnet for source FTP protocol"
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 172.17.32.36 --sport 21 -j ACCEPT

# FTP DATA rules
echo "-------------------------------------------"
echo "FTP DATA Port"
echo "Logging rules"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.36 --dport 50000:51000 -m limit --limit 10/sec -j LOG --log-prefix "FTP DATA PLANE FORWARD TO WS-32 - "
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 172.17.32.36 --sport 50000:51000 -m limit --limit 10/sec -j LOG --log-prefix "FTP DATA PLANE FORWARD FROM WS-32 - "
echo "allow any tcp traffic pass through Source WC-xx subnet to Destination LR-xx for destination FTP protocol"
iptables -A FORWARD -p tcp -s 10.52.19.0/24 -d 172.17.32.36 --dport 50000:51000 -j ACCEPT
echo "allow any tcp traffic pass through Source LS -xx to destination WC-xx subnet for source FTP protocol"
iptables -A FORWARD -p tcp -d 10.52.19.0/24 -s 172.17.32.36 --sport 50000:51000 -j ACCEPT


# Log before DROPPING
echo "-------------------------------------------"
echo "Add a rule to LOG instead of DROPPING FORWARD packets"
iptables -A FORWARD -p all -m limit --limit 10/s -j LOG --log-prefix "TO_DROP_FORWARD"

# Reject all other FORWARD traffic from this machine
 echo "-------------------------------------------"
 echo "Reject all other FORWARD traffic from this machine"
 iptables -A FORWARD -j DROP

# Allow all output traffic from this machine
echo "-------------------------------------------"
echo "Logging rules"
iptables -A OUTPUT -p tcp -d 10.52.19.0/24 -s 192.168.32.36 --sport 22 -m limit --limit 10/sec -j LOG --log-prefix "SSH OUTPUT WC-32"
echo "Allow all output traffic from this machine"
iptables -A OUTPUT -j ACCEPT

# List current iptables status
echo "-------------------------------------------"
echo "list current iptables status"
iptables -nvL --line
```

## Part C - Logging and Isolating Masqueraded Packets

## Part D - Azure Cost Analysis Charts