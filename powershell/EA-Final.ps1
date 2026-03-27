# This script illustrate that to create vNet with three subnet in one particular location


# Connect to your Azure Subscription

$subscription_id = "99be1db5-4f4a-4f12-9bb7-fc76e26d9a2e" 
Connect-AzAccount -Subscription $subscription_id

# Create a new ResourceGroup

$ea_location = "East Asia"
$ea_rgname = "EAST-ASIA-RG"
New-AzResourceGroup `
  -Name $ea_rgname `
  -Location $ea_location

# Provide ARM template file path and parameterFile path for vNet

$ea_vnet_templateFile = "D:\Personal\EMINE AZURE\Deliverables\ARM_TEMPLATES\EAST ASIA\vNet-Subnet\East_Asia_vNet.json"
$ea_vnet_parameterFile="D:\Personal\EMINE AZURE\Deliverables\ARM_TEMPLATES\EAST ASIA\vNet-Subnet\East_Asia_vNet.parameters.json"
 
# Create a vnet in azure using AzResourceGroupDeployment

New-AzResourceGroupDeployment `
  -Name EA-VNET-SUBNET `
  -ResourceGroupName $ea_rgname `
  -TemplateFile $ea_vnet_templateFile `
  -TemplateParameterFile $ea_vnet_parameterFile

##### CREATE ASG & NSG AND ASSOCIATE NSG WITH SUBNET #####
  
#Provide ARM template file path and parameterFile path for ASG

$ea_asg_templateFile = "D:\Personal\EMINE AZURE\Deliverables\ARM_TEMPLATES\EAST ASIA\ASG\ASG.json"
$ea_asg_parameterFile="D:\Personal\EMINE AZURE\Deliverables\ARM_TEMPLATES\EAST ASIA\ASG\ASG.parameters.json"

# Create a ASG in azure using AzResourceGroupDeployment

New-AzResourceGroupDeployment `
  -Name EA-ASG `
  -ResourceGroupName $ea_rgname `
  -TemplateFile $ea_asg_templateFile `
  -TemplateParameterFile $ea_asg_parameterFile

# Provide ARM template file path and parameterFile path for NSG

$ea_nsg_templateFile = "D:\Personal\EMINE AZURE\Deliverables\ARM_TEMPLATES\EAST ASIA\NSG-RULE\East_Asia_NSG_Security_Rule.json"
$ea_nsg_parameterFile= "D:\Personal\EMINE AZURE\Deliverables\ARM_TEMPLATES\EAST ASIA\NSG-RULE\East_Asia_NSG_Security_Rule.Parameters.json"

# Create NSG with security rule using deployment

New-AzResourceGroupDeployment `
  -Name EA-NSG-RULES `
  -ResourceGroupName $ea_rgname `
  -TemplateFile $ea_nsg_templateFile `
  -TemplateParameterFile $ea_nsg_parameterFile

### Retrieve exisitng vNet configuration ###

$ea_vnet_name = "EAST-ASIA-VNET-01" 
$ea_vnet = Get-AzVirtualNetwork -ResourceGroupName $ea_rgname -Name $ea_vnet_name
  
### Store exisitng subnet value into variable ### 
## Subnet added into variable, so change it when require

  $ea_snet_web_name = "EAST-ASIA-WEB-SUBNET"  
  $ea_snet_DMZ_name = "EAST-ASIA-DMZ-SUBNET"
  $ea_snet_DB_name = "EAST-ASIA-Database-SUBNET"

  $ea_subnet_DMZ = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $ea_vnet -Name $ea_snet_DMZ_name
  $ea_subnet_WEB = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $ea_vnet -Name $ea_snet_web_name
  $ea_subnet_DB = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $ea_vnet -Name $ea_snet_DB_name
  
### Retrieve Updated NSG information ###

  $ea_nsg_name = "EAST-ASIA-NSG-01"
  $ea_nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $ea_rgname -Name $ea_nsg_name 
  
### Associate subnet with NSG ###
   $ea_subnet_DMZ.NetworkSecurityGroup = $ea_nsg
   $ea_subnet_WEB.NetworkSecurityGroup = $ea_nsg
   $ea_subnet_DB.NetworkSecurityGroup = $ea_nsg
   
### Update Existig vNET ### 
   Set-AzVirtualNetwork -VirtualNetwork $ea_vnet
   
##########################################################################################################


#$subscription_id = "99be1db5-4f4a-4f12-9bb7-fc76e26d9a2e"  
#Connect-AzAccount -Subscription $subscription_id

$ea_rgname = "EAST-ASIA-RG" 

### BASTION HOST VARIABLE ###
$ea_Bastion_ASG_Name = "EA-BASTION-ASG-01"
$ea_snet_DMZ_name = "EAST-ASIA-DMZ-SUBNET"
$ea_Bastion_IPConfig_name = "EA-BASTION-IPCONFIG-01"
$ea_bastion_subnetid = "/subscriptions/$subscription_id/resourceGroups/$ea_rgname/providers/Microsoft.Network/virtualNetworks/$ea_vnet_name/subnets/$ea_snet_DMZ_name"
$ea_Bastion_NIC_name = "EA-BASTION-NIC-01"
$ea_bastion_vmname = "EA-BASTION-VM-1"
$ea_bastion_VMSize = "Standard_B2s"
$ea_bastion_credentials= Get-Credential -Message "Type the name and password of the BASTION administrator account." 
$ea_bastion_pip_name = "EA-BASTION-PIP"

### WEB HOST VARIABLE ###
$ea_Web_ASG_Name = "EA-WEBAPP-ASG-01"
$ea_snet_web_name = "EAST-ASIA-WEB-SUBNET"
$ea_Web_IPConfig_name = "EA-WEB-IPCONFIG-01"
$ea_web_subnetid = "/subscriptions/$subscription_id/resourceGroups/$ea_rgname/providers/Microsoft.Network/virtualNetworks/$ea_vnet_name/subnets/$ea_snet_WEB_name"
$ea_Web_NIC_name = "EA-WEB-NIC-01"
$ea_web_vmname = "EA-WEB-VM-1"
$ea_web_VMSize = "Standard_B1ms"
$ea_web_credentials = Get-Credential -Message "Type the name and password of the WEBHOST administrator account." 

#### MSSQL HOST VARIABLE ####
$ea_MSSQL_ASG_Name = "EA-MSSQL-ASG-01"
$ea_snet_DB_name = "EAST-ASIA-Database-SUBNET"
$ea_MSSQL_IPConfig_name = "EA-MSSQL-IPCONFIG-01"
$ea_mssql_subnetid = "/subscriptions/$subscription_id/resourceGroups/$ea_rgname/providers/Microsoft.Network/virtualNetworks/$ea_vnet_name/subnets/$ea_snet_DB_name" 
$ea_MSSQL_NIC_name = "EA-MSSQL-NIC-01"
$ea_mssql_vmname = "EA-MSSQL-VM-1"
$ea_mssql_VMSize = "Standard_B1ms"
$ea_mssql_credentials = Get-Credential -Message "Type the name and password of the MSSQL administrator account." ## KEEP USERNAME "sa" 



######## CREATE BASTION-(DMZ) VM ###########

# Initialze Bastion ASG value

$ea_Bastion_ASG_value = Get-AzApplicationSecurityGroup -Name $ea_Bastion_ASG_Name -ResourceGroupName $ea_rgname

# Create new public IP for bastion

$bastion_pip = New-AzPublicIpAddress -Name $ea_bastion_pip_name -ResourceGroupName $ea_rgname -AllocationMethod Dynamic -Location $ea_location

# Create a Network Interface IP Configuration
$ea_bastion_ipConfig = New-AzNetworkInterfaceIpConfig `
-Name $ea_Bastion_IPConfig_name `
-SubnetId $ea_bastion_subnetid `
-ApplicationSecurityGroupId $ea_Bastion_ASG_value.Id `
-PublicIpAddressId $bastion_pip.Id 


# Create the Network Interface
$ea_bastion_nic = New-AzNetworkInterface -Name $ea_Bastion_NIC_name `
-ResourceGroupName $ea_rgname `
-Location $ea_location `
-IpConfiguration $ea_bastion_ipConfig

# Create & Update VM properties

$ea_bastion_vmConfig = New-AzVMConfig -VMName $ea_bastion_vmname -VMSize $ea_bastion_VMSize 
$ea_bastion_vmConfig = Set-AzVMOperatingSystem -VM $ea_bastion_vmConfig -Windows -ComputerName $ea_bastion_vmname -Credential $ea_bastion_credentials -ProvisionVMAgent -EnableAutoUpdate
$ea_bastion_vmConfig = Add-AzVMNetworkInterface -VM $ea_bastion_vmConfig -Id $ea_bastion_nic.Id
$ea_bastion_vmConfig = Set-AzVMSourceImage -VM $ea_bastion_vmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" 

#Create VM for Bastion

New-AzVM -ResourceGroupName $ea_rgname `
-Location $ea_location `
-VM $ea_bastion_vmConfig `
-Verbose

# Fetch Public IP to connect BASTION (DMZ) VM

$ea_bastion_pip_value = Get-AzPublicIpAddress -Name $ea_bastion_pip_name -ResourceGroupName $ea_rgname

# connect to Bastion VM using RDP
# PUBLIC IP will require to change

mstsc /v $ea_bastion_pip_value.IpAddress

####### Create WEB VM ########

# Initialze WEB ASG value

$ea_Web_ASG_value = Get-AzApplicationSecurityGroup -Name $ea_Web_ASG_Name -ResourceGroupName $ea_rgname


#Create a Network Interface IP Configuration

$ea_Web_ipconfig = New-AzNetworkInterfaceIpConfig `
-Name $ea_Web_IPConfig_name  `
-SubnetId $ea_web_subnetid `
-ApplicationSecurityGroupId $ea_Web_ASG_value.Id
 

# Create the Network Interface
$ea_web_nic = New-AzNetworkInterface -Name $ea_Web_NIC_name `
-ResourceGroupName $ea_rgname `
-Location $ea_location `
-IpConfiguration $ea_Web_ipconfig

# Create & Update VM properties

$ea_web_vmConfig = New-AzVMConfig -VMName $ea_web_vmname -VMSize $ea_web_VMSize 
$ea_web_vmConfig = Set-AzVMOperatingSystem -VM $ea_web_vmConfig -Windows -ComputerName $ea_web_vmname -Credential $ea_web_credentials -ProvisionVMAgent -EnableAutoUpdate
$ea_web_vmConfig = Add-AzVMNetworkInterface -VM $ea_web_vmConfig -Id $ea_web_nic.Id
$ea_web_vmConfig = Set-AzVMSourceImage -VM $ea_web_vmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" 

#Create VM for WEB

New-AzVM -ResourceGroupName $ea_rgname `
-Location $ea_location `
-VM $ea_web_vmConfig


# Install Customscript extension and webpage

$publicSettings = @{ "fileUris" = (,"https://raw.githubusercontent.com/eoncu3841/EA-sample-webpage/main/ea-sample-webpage.ps1");  "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File ea-sample-webpage.ps1" }

Set-AzVMExtension -ResourceGroupName $ea_rgname `
    -ExtensionName "IIS" `
    -VMName $ea_web_vmname `
    -Location $ea_location `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -Settings $publicSettings `
    -verbose
    ##-SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername) "}'


##### CREATE MSSQL VM #####

# Initialze MSSQL ASG value

$ea_MSSQL_ASG_value = Get-AzApplicationSecurityGroup -Name $ea_MSSQL_ASG_Name -ResourceGroupName $ea_rgname

#Create a Network Interface IP Configuration

$ea_MSSQL_ipconfig = New-AzNetworkInterfaceIpConfig `
-Name $ea_MSSQL_IPConfig_name  `
-SubnetId $ea_mssql_subnetid `
-ApplicationSecurityGroupId $ea_MSSQL_ASG_value.Id

# Create the Network Interface

$ea_mssql_nic = New-AzNetworkInterface -Name $ea_MSSQL_NIC_name `
-ResourceGroupName $ea_rgname `
-Location $ea_location `
-IpConfiguration $ea_MSSQL_ipConfig


# Create & Update VM properties

$ea_mssql_vmConfig = New-AzVMConfig -VMName $ea_mssql_vmname -VMSize $ea_mssql_VMSize 
$ea_mssql_vmConfig = Set-AzVMOperatingSystem -VM $ea_mssql_vmConfig -Windows -ComputerName $ea_mssql_vmname -Credential $ea_mssql_credentials -ProvisionVMAgent -EnableAutoUpdate
$ea_mssql_vmConfig = Add-AzVMNetworkInterface -VM $ea_mssql_vmConfig -Id $ea_mssql_nic.Id
$ea_mssql_vmConfig = Set-AzVMSourceImage -VM $ea_mssql_vmConfig -PublisherName "MicrosoftSQLServer" -Offer "SQL2017-WS2016" -Skus "SQLDEV" -Version "latest" 

#Create VM for MSSQL

New-AzVM -ResourceGroupName $ea_rgname `
-Location $ea_location `
-VM $ea_mssql_vmConfig

