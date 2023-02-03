#!/bin/bash

# gets az current version running in this system
echo "--------------------------------------------"
echo " Get the current running SDK version"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
az --version

# gets all current subscriptions in json
echo "-----------------------------------------------"
echo " List current subscriptions in this system in json format"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
az account list

# gets resource groups
echo "-----------------------------------------------"
echo " List all Resource Groups in the subscription"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
az group list --output table


