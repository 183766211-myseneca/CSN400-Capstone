Part C
4. output of `az network vnet subnet show -g "Student-RG-846011" -n "SN1" --vnet-name "Server-32" --query "[type, addressPrefix, routeTable]"`
[
  "Microsoft.Network/virtualNetworks/subnets",
  "172.17.32.32/27",
  {
    "id": "/subscriptions/bd627181-5ddb-4bb6-b03f-5297c3be4e1e/resourceGroups/Student-RG-846011/providers/Microsoft.Network/routeTables/RT-32",
    "resourceGroup": "Student-RG-846011"
  }
]
