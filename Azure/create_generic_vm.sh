#!/bin/bash
#
# Name:
# Description: Create a VM in Azure
#

#--------------------------------------
# function Usage
#--------------------------------------
function Usage() {
  msg="$1"
  echo "$msg"
  echo "Usage: $0 \\"
  echo "          -n NAMESPACE \\"
  echo "          -z VMSIZE \\"
  echo "         [-s name of VM suffix (default is the OS_Type)]   \\"
  echo "         [-o OS_Type(rhel/centos/centos8/ubu/KUKU default is centos)]   \\"
  echo "         [-c Count_of_VMs (up to 5.default is 1)]          \\"
  echo "         [-r NUMSTART (from which num to start vm count. default is 1)]          \\"
  echo "         [-t (Thumbnail yes/no - default no)]              \\"
  echo "         [-v (Validate  yes/no - default no)]"
  echo "Example: $0 -n beitar -s jlm -o rhel -c 3"
  echo " This will create 3 rhel VMs with the names beitar-jlm-1, beitar-jlm-2, beitar-jlm-3"
  echo "VMSIZE could be Standard_E16s_v3/Standard_B16ms/Standard_L16s_v2/Standard_DS14_v2/Standard_E20as_v4/Standard_D2s_v3 etc."
  exit 1
}
#--------------------------------------
# function get_parameters
#--------------------------------------
function get_parameters()
{
echo function get_parameters

let VMCOUNT=1
export THUMBNAIL=no
export TYPEOS=centos
export VALIDATE=""
#export VMSIZE=Standard_E16s_v3
#export VMSIZE=Standard_B16ms
#export VMSIZE=Standard_L16s_v2
#export VMSIZE=Standard_DS14_v2
#export VMSIZE=Standard_E20as_v4
#export VMSIZE=Standard_D2s_v3
export NUMSTART=1
while getopts n:s:c:o:z:r:tv opt
do
      case $opt in
         n) NAMESPACE=$(echo $OPTARG | tr 'A-Z' 'a-z')
            ;;
         s) SUFFIX=$(echo $OPTARG | tr 'A-Z' 'a-z')
            ;;
         z) VMSIZE=$OPTARG
            ;;
         o) TYPEOS=$(echo $OPTARG | tr 'A-Z' 'a-z')
            ;;
         r) let NUMSTART=$OPTARG
            ;;
         c) let VMCOUNT=$OPTARG
            ;;
         v) VALIDATE="--validate"
            ;;
         t) THUMBNAIL=yes
            ;;
         *) Usage
            ;;
      esac
done
[[ -z "$NAMESPACE" ]] && Usage "Error: Missing namespace"
if [ $TYPEOS = "rhel" ]; then
  export VMIMAGEREF="RedHat:RHEL:7-LVM:latest"
elif [ $TYPEOS = "ubu" ]; then
  export VMIMAGEREF="Canonical:UbuntuServer:16.04-LTS:latest" 
elif [ $TYPEOS = "centos" ]; then
  export VMIMAGEREF="OpenLogic:CentOS:7.5:latest"
elif [ $TYPEOS = "centos8" ]; then
  export VMIMAGEREF="OpenLogic:CentOS:8.0:latest"
elif [ $TYPEOS = "KUKU" ]; then
  export VMIMAGEREF="/subscriptions/SUBSCRIPTION/resourceGroups/shared-images-rg/providers/Microsoft.Compute/galleries/KUKU_os_images/images/centos76"
else
  Usage "Error: OS Type is not 'rhel' / 'ubu' / 'centos' / 'centos8' / 'KUKU'"
fi
if [ $VMCOUNT -lt 1 -o $VMCOUNT -gt 10 ]
then
  Usage "Error: Number of VMs is not between 1 and 5"
fi
if [ $THUMBNAIL = "yes" ]; then
  t=yes
elif [ $THUMBNAIL = "no" ]; then
  t=no
else
  Usage "Thumbnail is not 'yes' or 'no'"
fi
[[ -z "$SUFFIX" ]] && export SUFFIX=$TYPEOS

echo NAMESPACE  = $NAMESPACE
echo SUFFIX     = $SUFFIX
echo TYPEOS     = $TYPEOS
echo VMCOUNT    = $VMCOUNT
echo THUMBNAIL  = $THUMBNAIL
echo VALIDATE   = $VALIDATE
}
#--------------------------------------
# function install_thmb_ubu
#--------------------------------------
function install_thmb_ubu()
{
time ssh root@aia-aks-account ssh IP ssh brain@$VMIP sudo apt-get update
time ssh root@aia-aks-account ssh IP ssh brain@$VMIP sudo apt-get install nodejs-legacy -y
time ssh root@aia-aks-account ssh IP ssh brain@$VMIP sudo apt-get install npm -y
time ssh root@aia-aks-account scp /BD/SW/Google/google-chrome-stable_current_deb IP:Packages/.
time ssh root@aia-aks-account ssh IP scp Packages/google-chrome-stable_current.deb brain@$VMIP:.
time ssh root@aia-aks-account ssh IP ssh brain@$VMIP sudo dpkg -i google-chrome-stable_current.deb
time ssh root@aia-aks-account ssh IP ssh brain@$VMIP sudo apt-get install -f -y
time ssh root@aia-aks-account ssh IP ssh brain@$VMIP npm --version
time ssh root@aia-aks-account ssh IP ssh brain@$VMIP google-chrome --version
}

get_parameters $*

LOCATION=northeurope
RESOURCE_GROUP=${NAMESPACE}-rg

VMVNETNAME=/subscriptions/SUBSCRIPTION/resourceGroups/di-vnet-rg/providers/Microsoft.Network/virtualNetworks/DI-Vnet2
VMSUBNETID=/subscriptions/SUBSCRIPTION/resourceGroups/di-vnet-rg/providers/Microsoft.Network/virtualNetworks/DI-Vnet2/subnets/DI-Vnet-AKS-subnet

date
echo time ssh root@aia-aks-account az group create -l ${LOCATION} -n ${RESOURCE_GROUP}
time ssh root@aia-aks-account az group create -l ${LOCATION} -n ${RESOURCE_GROUP}

date
echo DEBUG: for i in `seq $NUMSTART $VMCOUNT`
for i in `seq $NUMSTART $VMCOUNT`
do
  VMNAME=${NAMESPACE}-${SUFFIX}-$i
  echo VMNAME=${VMNAME}
  log=/tmp/${VMNAME}.log
  echo time ssh root@aia-aks-account \
  az vm create -n                   ${VMNAME}          \
                -g                   ${RESOURCE_GROUP}  \
                -l                   ${LOCATION}        \
               --image               $VMIMAGEREF        \
               --os-disk-size-gb     100                \
               --priority            Regular            \
               --size                $VMSIZE            \
               ${VALIDATE}                              \
               --authentication-type password           \
               --admin-username      brain              \
               --admin-password      PASSWOD  \
               --subnet              ${VMSUBNETID}      \
               --public-ip-address   '""'             
  time ssh root@aia-aks-account \
  az vm create -n                   ${VMNAME}          \
                -g                   ${RESOURCE_GROUP}  \
                -l                   ${LOCATION}        \
               --image               $VMIMAGEREF        \
               --os-disk-size-gb     100                \
               --priority            Regular            \
               --size                $VMSIZE            \
               ${VALIDATE}                              \
               --authentication-type password           \
               --admin-username      brain              \
               --admin-password      PASSWOD  \
               --subnet              ${VMSUBNETID}      \
               --public-ip-address   '""'               \
               2>&1 | tee $log

#               --data-disk-sizes-gb  1024               \
#               --os-disk-name        ${VMNAME}-OS-DISK  \
#               --os-disk-size-gb    100                 \

  date
  if [ -z "${VALIDATE}" ];then
    VMIP=$(awk -F: '/"privateIpAddress"/{print $2}' $log | sed 's/"//g' | sed 's/,//g' | sed 's/ //g')
    if [ -n "${VMIP}" ];then
      ssh root@aia-aks-account ssh IP sed -i '/'${VMIP}'/d' .ssh/\* /etc/hosts
      ssh root@aia-aks-account ssh IP /usr/bin/sshpass -p PASSWOD ssh-copy-id -o StrictHostKeyChecking=no brain@$VMIP
      ssh root@aia-aks-account ssh IP ssh brain@$VMIP hostname
      ssh root@aia-aks-account ssh IP "echo $VMIP $VMNAME >> /etc/hosts"
    fi
  fi
done

exit



# Additional Info for creating VMs
#VMIMAGEREF="OpenLogic:CentOS:7.5:latest"
#VMIMAGEREF="CoreOS:CoreOS:Stable:latest"
#VMIMAGEREF="Debian:debian-10:10:latest"
#VMIMAGEREF="SUSE:openSUSE-Leap:42.3:latest"
#VMIMAGEREF="SUSE:SLES:15:latest"
#VMIMAGEREF="Canonical:UbuntuServer:18.04-LTS:latest"
#VMIMAGEREF="MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest"
#VMIMAGEREF="MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest"
#VMIMAGEREF="MicrosoftWindowsServer:WindowsServer:2012-R2-Datacenter:latest"
#VMIMAGEREF="MicrosoftWindowsServer:WindowsServer:2012-Datacenter:latest"
#VMIMAGEREF="MicrosoftWindowsServer:WindowsServer:2008-R2-SP1:latest"
#VMIMAGEREF="RedHat:RHEL:7-LVM:latest"
#VMIMAGEREF="Canonical:UbuntuServer:16.04-LTS:latest" 





Command
    az vm create : Create an Azure Virtual Machine.
        For an end-to-end tutorial, see https://docs.microsoft.com/azure/virtual-machines/virtual-
        machines-linux-quick-create-cli.

Arguments
    --name -n           [Required] : Name of the virtual machine.
    --resource-group -g [Required] : Name of resource group. You can configure the default group
                                     using `az configure --defaults group=<name>`.
    --availability-set             : Name or ID of an existing availability set to add the VM to.
                                     None by default.
    --boot-diagnostics-storage     : Pre-existing storage account name or its blob uri to capture
                                     boot diagnostics. Its sku should be one of Standard_GRS,
                                     Standard_LRS and Standard_RAGRS.
    --computer-name                : The host OS name of the virtual machine. Defaults to the name
                                     of the VM.
    --custom-data                  : Custom init script file or text (cloud-init, cloud-config,
                                     etc..).
    --enable-agent                 : Indicates whether virtual machine agent should be provisioned
                                     on the virtual machine. When this property is not specified,
                                     default behavior is to set it to true. This will ensure that VM
                                     Agent is installed on the VM so that extensions can be added to
                                     the VM later.  Allowed values: false, true.
    --eviction-policy              : The eviction policy for the Spot priority virtual machine.
                                     Default eviction policy is Deallocate for a Spot priority
                                     virtual machine.  Allowed values: Deallocate, Delete.
    --image                        : The name of the operating system image as a URN alias, URN,
                                     custom image name or ID, custom image version ID, or VHD blob
                                     URI. This parameter is required unless using `--attach-os-
                                     disk.` Valid URN format: "Publisher:Offer:Sku:Version".  Values
                                     from: az vm image list, az vm image show.
    --license-type                 : Specifies that the Windows image or disk was licensed on-
                                     premises. To enable Azure Hybrid Benefit for Windows Server,
                                     use 'Windows_Server'. To enable Multitenant Hosting Rights for
                                     Windows 10, use 'Windows_Client'. For more information see the
                                     Azure Windows VM online docs.  Allowed values: None,
                                     Windows_Client, Windows_Server.
    --location -l                  : Location in which to create VM and related resources. If
                                     default location is not configured, will default to the
                                     resource groups location.
    --max-price          [Preview] : The maximum price (in US Dollars) you are willing to
                                     pay for a Spot VM/VMSS. -1 indicates that the Spot VM/VMSS
                                     should not be evicted for price reasons.
        Argument '--max-price' is in preview. It may be changed/removed in a future
        release.
    --no-wait                      : Do not wait for the long-running operation to finish.
    --ppg                          : The name or ID of the proximity placement group the VM should
                                     be associated with.
    --priority                     : Priority. Use 'Spot' to run short-lived workloads in a cost-
                                     effective way. 'Low' enum will be deprecated in the future.
                                     Please use 'Spot' to deploy Azure spot VM and/or VMSS. Default
                                     to Regular.  Allowed values: Low, Regular, Spot.
    --secrets                      : One or many Key Vault secrets as JSON strings or files via
                                     `@{path}` containing `[{ "sourceVault": { "id": "value" },
                                     "vaultCertificates": [{ "certificateUrl": "value",
                                     "certificateStore": "cert store name (only on windows)"}] }]`.
    --size                         : The VM size to be created. See
                                     https://azure.microsoft.com/pricing/details/virtual-machines/
                                     for size info.  Default: Standard_DS1_v2.  Values from: az vm
                                     list-sizes.
    --tags                         : Space-separated tags: key[=value] [key[=value] ...]. Use '' to
                                     clear existing tags.
    --validate                     : Generate and validate the ARM template without creating any
                                     resources.
    --vmss                         : Name or ID of an existing virtual machine scale set that the
                                     virtual machine should be assigned to. None by default.
    --zone -z                      : Availability zone into which to provision the resource.
                                     Allowed values: 1, 2, 3.

Authentication Arguments
    --admin-password               : Password for the VM if authentication type is 'Password'.
    --admin-username               : Username for the VM. Default value is current username of OS.
                                     If the default value is system reserved, then default value
                                     will be set to azureuser. Please refer to
                                     https://docs.microsoft.com/en-
                                     us/rest/api/compute/virtualmachines/createorupdate#osprofile to
                                     get a full list of reserved values.
    --authentication-type          : Type of authentication to use with the VM. Defaults to password
                                     for Windows and SSH public key for Linux. "all" enables both
                                     ssh and password authentication.  Allowed values: all,
                                     password, ssh.
    --generate-ssh-keys            : Generate SSH public and private key files if missing. The keys
                                     will be stored in the ~/.ssh directory.
    --ssh-dest-key-path            : Destination file path on the VM for the SSH key. If the file
                                     already exists, the specified key(s) are appended to the file.
                                     Destination path for SSH public keys is currently limited to
                                     its default value "/home/username/.ssh/authorized_keys" due to
                                     a known issue in Linux provisioning agent.
    --ssh-key-values               : Space-separated list of SSH public keys or public key file
                                     paths.

Dedicated Host Arguments
    --host               [Preview] : Name or ID of the dedicated host this VM will reside
                                     in. If a name is specified, a host group must be specified via
                                     `--host-group`.
        Argument '--host' is in preview. It may be changed/removed in a future release.
    --host-group         [Preview] : Name of the dedicated host group containing the
                                     dedicated host this VM will reside in.
        Argument '--host-group' is in preview. It may be changed/removed in a future
        release.

Managed Service Identity Arguments
    --assign-identity              : Accept system or user assigned identities separated by spaces.
                                     Use '[system]' to refer system assigned identity, or a resource
                                     id to refer user assigned identity. Check out help for more
                                     examples.
    --role                         : Role name or id the system assigned identity will have.
                                     Default: Contributor.
    --scope                        : Scope that the system assigned identity can access.

Marketplace Image Plan Arguments
    --plan-name                    : Plan name.
    --plan-product                 : Plan product.
    --plan-promotion-code          : Plan promotion code.
    --plan-publisher               : Plan publisher.

Monitor Arguments
    --workspace          [Preview] : Name or ID of Log Analytics Workspace. If you specify
                                     the workspace through its name, the workspace should be in the
                                     same resource group with the vm, otherwise a new workspace will
                                     be created.
        Argument '--workspace' is in preview. It may be changed/removed in a future
        release.

Network Arguments
    --accelerated-networking       : Enable accelerated networking. Unless specified, CLI will
                                     enable it based on machine image and size.  Allowed values:
                                     false, true.
    --asgs                         : Space-separated list of existing application security groups to
                                     associate with the VM.
    --nics                         : Names or IDs of existing NICs to attach to the VM. The first
                                     NIC will be designated as primary. If omitted, a new NIC will
                                     be created. If an existing NIC is specified, do not specify
                                     subnet, VNet, public IP or NSG.
    --nsg                          : The name to use when creating a new Network Security Group
                                     (default) or referencing an existing one. Can also reference an
                                     existing NSG by ID or specify "" for none ('""' in Azure CLI
                                     using PowerShell or --% operator).
    --nsg-rule                     : NSG rule to create when creating a new NSG. Defaults to open
                                     ports for allowing RDP on Windows and allowing SSH on Linux.
                                     NONE represents no NSG rule.  Allowed values: NONE, RDP, SSH.
    --private-ip-address           : Static private IP address (e.g. 10.0.0.5).
    --public-ip-address            : Name of the public IP address when creating one (default) or
                                     referencing an existing one. Can also reference an existing
                                     public IP by ID or specify "" for None ('""' in Azure CLI using
                                     PowerShell or --% operator).
    --public-ip-address-allocation : Allowed values: dynamic, static.
    --public-ip-address-dns-name   : Globally unique DNS name for a newly created public IP.
    --public-ip-sku                : Public IP SKU. It is set to Basic by default.  Allowed values:
                                     Basic, Standard.
    --subnet                       : The name of the subnet when creating a new VNet or referencing
                                     an existing one. Can also reference an existing subnet by ID.
                                     If both vnet-name and subnet are omitted, an appropriate VNet
                                     and subnet will be selected automatically, or a new one will be
                                     created.
    --subnet-address-prefix        : The subnet IP address prefix to use when creating a new VNet in
                                     CIDR format.  Default: 10.0.0.0/24.
    --vnet-address-prefix          : The IP address prefix to use when creating a new VNet in CIDR
                                     format.  Default: 10.0.0.0/16.
    --vnet-name                    : Name of the virtual network when creating a new one or
                                     referencing an existing one.

Storage Arguments
    --attach-data-disks            : Attach existing data disks to the VM. Can use the name or ID of
                                     a managed disk or the URI to an unmanaged disk VHD.
    --attach-os-disk               : Attach an existing OS disk to the VM. Can use the name or ID of
                                     a managed disk or the URI to an unmanaged disk VHD.
    --data-disk-caching            : Storage caching type for data disk(s), including 'None',
                                     'ReadOnly', 'ReadWrite', etc. Use a singular value to apply on
                                     all disks, or use `<lun>=<vaule1> <lun>=<value2>` to configure
                                     individual disk.
    --data-disk-encryption-sets    : Names or IDs (space delimited) of disk encryption sets for data
                                     disks.
    --data-disk-sizes-gb           : Space-separated empty managed data disk sizes in GB to create.
    --encryption-at-host           : Enable Host Encryption for the VM or VMSS. This will enable the
                                     encryption for all the disks including Resource/Temp disk at
                                     host itself.  Allowed values: false, true.
    --ephemeral-os-disk  [Preview] : Allows you to create an OS disk directly on the host
                                     node, providing local disk performance and faster VM/VMSS
                                     reimage time.  Allowed values: false, true.
        Argument '--ephemeral-os-disk' is in preview. It may be changed/removed in a future
        release.
    --os-disk-caching              : Storage caching type for the VM OS disk. Default: ReadWrite.
                                     Allowed values: None, ReadOnly, ReadWrite.
    --os-disk-encryption-set       : Name or ID of disk encryption set for OS disk.
    --os-disk-name                 : The name of the new VM OS disk.
    --os-disk-size-gb              : OS disk size in GB to create.
    --os-type                      : Type of OS installed on a custom VHD. Do not use when
                                     specifying an URN or URN alias.  Allowed values: linux,
                                     windows.
    --specialized                  : Indicate whether the source image is specialized.  Allowed
                                     values: false, true.
    --storage-account              : Only applicable when used with `--use-unmanaged-disk`. The name
                                     to use when creating a new storage account or referencing an
                                     existing one. If omitted, an appropriate storage account in the
                                     same resource group and location will be used, or a new one
                                     will be created.
    --storage-container-name       : Only applicable when used with `--use-unmanaged-disk`. Name of
                                     the storage container for the VM OS disk. Default: vhds.
    --storage-sku                  : The SKU of the storage account with which to persist VM. Use a
                                     singular sku that would be applied across all disks, or specify
                                     individual disks. Usage: [--storage-sku SKU | --storage-sku
                                     ID=SKU ID=SKU ID=SKU...], where each ID is "os" or a 0-indexed
                                     lun. Allowed values: Standard_LRS, Premium_LRS,
                                     StandardSSD_LRS, UltraSSD_LRS.
    --ultra-ssd-enabled            : Enables or disables the capability to have 1 or more managed
                                     data disks with UltraSSD_LRS storage account.  Allowed values:
                                     false, true.
    --use-unmanaged-disk           : Do not use managed disk to persist VM.

Global Arguments
    --debug                        : Increase logging verbosity to show all debug logs.
    --help -h                      : Show this help message and exit.
    --only-show-errors             : Only show errors, suppressing warnings.
    --output -o                    : Output format.  Allowed values: json, jsonc, none, table, tsv,
                                     yaml, yamlc.  Default: json.
    --query                        : JMESPath query string. See http://jmespath.org/ for more
                                     information and examples.
    --subscription                 : Name or ID of subscription. You can configure the default
                                     subscription using `az account set -s NAME_OR_ID`.
    --verbose                      : Increase logging verbosity. Use --debug for full debug logs.

Examples
    Create a default Ubuntu VM with automatic SSH authentication.
        az vm create -n MyVm -g MyResourceGroup --image UbuntuLTS


    Create a default RedHat VM with automatic SSH authentication using an image URN.
        az vm create -n MyVm -g MyResourceGroup --image RedHat:RHEL:7-RAW:7.4.2018010506


    Create a default Windows Server VM with a private IP address.
        az vm create -n MyVm -g MyResourceGroup --public-ip-address "" --image Win2012R2Datacenter


    Create a VM from a custom managed image.
        az vm create -g MyResourceGroup -n MyVm --image MyImage


    Create a VM from a specialized image version.
        az vm create -g MyResourceGroup -n MyVm --image $id --specialized


    Create a VM by attaching to a managed operating system disk.
        az vm create -g MyResourceGroup -n MyVm --attach-os-disk MyOsDisk --os-type linux


    Create an Ubuntu Linux VM using a cloud-init script for configuration. See:
    https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-using-cloud-init.
        az vm create -g MyResourceGroup -n MyVm --image debian --custom-data MyCloudInitScript.yml


    Create a Debian VM with SSH key authentication and a public DNS entry, located on an existing
    virtual network and availability set.
        az vm create -n MyVm -g MyResourceGroup --image debian --vnet-name MyVnet --subnet subnet1 \
            --availability-set MyAvailabilitySet --public-ip-address-dns-name MyUniqueDnsName \
            --ssh-key-values @key-file


    Create a simple Ubuntu Linux VM with a public IP address, DNS entry, two data disks (10GB and
    20GB), and then generate ssh key pairs.
        az vm create -n MyVm -g MyResourceGroup --public-ip-address-dns-name MyUniqueDnsName \
            --image ubuntults --data-disk-sizes-gb 10 20 --size Standard_DS2_v2 \
            --generate-ssh-keys


    Create a Debian VM using Key Vault secrets.
        az keyvault certificate create --vault-name vaultname -n cert1 \
          -p "$(az keyvault certificate get-default-policy)"

        secrets=$(az keyvault secret list-versions --vault-name vaultname \
          -n cert1 --query "[?attributes.enabled].id" -o tsv)

        vm_secrets=$(az vm secret format -s "$secrets")

        az vm create -g group-name -n vm-name --admin-username deploy  \
          --image debian --secrets "$vm_secrets"


    Create a CentOS VM with a system assigned identity. The VM will have a 'Contributor' role with
    access to a storage account.
        az vm create -n MyVm -g rg1 --image centos --assign-identity --scope
        /subscriptions/99999999-1bf0-4dda-
        aec3-cb9272f09590/MyResourceGroup/myRG/providers/Microsoft.Storage/storageAccounts/storage1


    Create a debian VM with a user assigned identity.
        az vm create -n MyVm -g rg1 --image debian --assign-identity
        /subscriptions/SUBSCRIPTION/resourcegroups/myRG/providers/Microsoft.
        ManagedIdentity/userAssignedIdentities/myID


    Create a debian VM with both system and user assigned identity.
        az vm create -n MyVm -g rg1 --image debian --assign-identity  [system]
        /subscriptions/SUBSCRIPTION/resourcegroups/myRG/providers/Microsoft.
        ManagedIdentity/userAssignedIdentities/myID


    Create a VM in an availability zone in the current resource group's region
        az vm create -n MyVm -g MyResourceGroup --image Centos --zone 1


For more specific examples, use: az find "az vm create"

Please let us know how we are doing: https://aka.ms/azureclihats
