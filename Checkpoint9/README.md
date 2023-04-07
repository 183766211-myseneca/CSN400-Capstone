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

## Part C - Logging and Isolating Masqueraded Packets

## Part D - Azure Cost Analysis Charts