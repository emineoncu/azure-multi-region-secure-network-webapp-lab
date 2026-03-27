

$subscription_id = "99be1db5-4f4a-4f12-9bb7-fc76e26d9a2e"  
Connect-AzAccount -Subscription $subscription_id

$eu_rgname = "EAST-US-RG" 

### BASTION HOST VARIABLE ###
$eu_Bastion_ASG_Name = "EU-BASTION-ASG-01"
$eu_snet_DMZ_name = "EAST-US-DMZ-SUBNET"
$eu_Bastion_IPConfig_name = "EU-BASTION-IPCONFIG-01"
$eu_bastion_subnetid = "/subscriptions/$subscription_id/resourceGroups/$eu_rgname/providers/Microsoft.Network/virtualNetworks/$eu_vnet_name/subnets/$eu_snet_DMZ_name"
$eu_Bastion_NIC_name = "EU-BASTION-NIC-01"
$eu_bastion_vmname = "EU-BASTION-VM-1"
$eu_bastion_VMSize = "Standard_B2s"
$eu_bastion_credentials= Get-Credential -Message "Type the name and password of the BASTION administrator account." 
$eu_bastion_pip_name = "EU-BASTION-PIP"

### WEB HOST VARIABLE ###
$eu_Web_ASG_Name = "EU-WEBAPP-ASG-01"
$eu_snet_web_name = "EAST-US-WEB-SUBNET"
$eu_Web_IPConfig_name = "EU-WEB-IPCONFIG-01"
$eu_web_subnetid = "/subscriptions/$subscription_id/resourceGroups/$eu_rgname/providers/Microsoft.Network/virtualNetworks/$eu_vnet_name/subnets/$eu_snet_WEB_name"
$eu_Web_NIC_name = "EU-WEB-NIC-01"
$eu_web_vmname = "EU-WEB-VM-1"
$eu_web_VMSize = "Standard_B1ms"
$eu_web_credentials = Get-Credential -Message "Type the name and password of the WEBHOST administrator account." 

#### MSSQL HOST VARIABLE ####
$eu_MSSQL_ASG_Name = "EU-MSSQL-ASG-01"
$eu_snet_DB_name = "EAST-US-Database-SUBNET"
$eu_MSSQL_IPConfig_name = "EU-MSSQL-IPCONFIG-01"
$eu_mssql_subnetid = "/subscriptions/$subscription_id/resourceGroups/$eu_rgname/providers/Microsoft.Network/virtualNetworks/$eu_vnet_name/subnets/$eu_snet_DB_name" 
$eu_MSSQL_NIC_name = "EU-MSSQL-NIC-01"
$eu_mssql_vmname = "EU-MSSQL-VM-1"
$eu_mssql_VMSize = "Standard_B1ms"
$eu_mssql_credentials = Get-Credential -Message "Type the name and password of the MSSQL administrator account." ## KEEP USERNAME "sa" 



######## CReuTE BASTION-(DMZ) VM ###########

# Initialze Bastion ASG value

$eu_Bastion_ASG_value = Get-AzApplicationSecurityGroup -Name $eu_Bastion_ASG_Name -ResourceGroupName $eu_rgname

# Creute new public IP for bastion

$bastion_pip = New-AzPublicIpAddress -Name $eu_bastion_pip_name -ResourceGroupName $eu_rgname -AllocationMethod Dynamic -Location $eu_location

# Creute a Network Interface IP Configuration
$eu_bastion_ipConfig = New-AzNetworkInterfaceIpConfig `
-Name $eu_Bastion_IPConfig_name `
-SubnetId $eu_bastion_subnetid `
-ApplicationSecurityGroupId $eu_Bastion_ASG_value.Id `
-PublicIpAddressId $bastion_pip.Id 


# Creute the Network Interface
$eu_bastion_nic = New-AzNetworkInterface -Name $eu_Bastion_NIC_name `
-ResourceGroupName $eu_rgname `
-Location $eu_location `
-IpConfiguration $eu_bastion_ipConfig

# Creute & Update VM properties

$eu_bastion_vmConfig = New-AzVMConfig -VMName $eu_bastion_vmname -VMSize $eu_bastion_VMSize 
$eu_bastion_vmConfig = Set-AzVMOperatingSystem -VM $eu_bastion_vmConfig -Windows -ComputerName $eu_bastion_vmname -Credential $eu_bastion_credentials -ProvisionVMAgent -EnableAutoUpdate
$eu_bastion_vmConfig = Add-AzVMNetworkInterface -VM $eu_bastion_vmConfig -Id $eu_bastion_nic.Id
$eu_bastion_vmConfig = Set-AzVMSourceImage -VM $eu_bastion_vmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" 

#Creute VM for Bastion

New-AzVM -ResourceGroupName $eu_rgname `
-Location $eu_location `
-VM $eu_bastion_vmConfig `
-Verbose

# Fetch Public IP to connect BASTION (DMZ) VM

$eu_bastion_pip_value = Get-AzPublicIpAddress -Name $eu_bastion_pip_name -ResourceGroupName $eu_rgname

# connect to Bastion VM using RDP
# PUBLIC IP will require to change

mstsc /v $eu_bastion_pip_value.IpAddress

####### Creute WEB VM ########

# Initialze WEB ASG value

$eu_Web_ASG_value = Get-AzApplicationSecurityGroup -Name $eu_Web_ASG_Name -ResourceGroupName $eu_rgname


#Creute a Network Interface IP Configuration

$eu_Web_ipconfig = New-AzNetworkInterfaceIpConfig `
-Name $eu_Web_IPConfig_name  `
-SubnetId $eu_web_subnetid `
-ApplicationSecurityGroupId $eu_Web_ASG_value.Id
 

# Creute the Network Interface
$eu_web_nic = New-AzNetworkInterface -Name $eu_Web_NIC_name `
-ResourceGroupName $eu_rgname `
-Location $eu_location `
-IpConfiguration $eu_Web_ipconfig

# Creute & Update VM properties

$eu_web_vmConfig = New-AzVMConfig -VMName $eu_web_vmname -VMSize $eu_web_VMSize 
$eu_web_vmConfig = Set-AzVMOperatingSystem -VM $eu_web_vmConfig -Windows -ComputerName $eu_web_vmname -Credential $eu_web_credentials -ProvisionVMAgent -EnableAutoUpdate
$eu_web_vmConfig = Add-AzVMNetworkInterface -VM $eu_web_vmConfig -Id $eu_web_nic.Id
$eu_web_vmConfig = Set-AzVMSourceImage -VM $eu_web_vmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" 

#Creute VM for WEB

New-AzVM -ResourceGroupName $eu_rgname `
-Location $eu_location `
-VM $eu_web_vmConfig


# Install Customscript extension and webpage

$publicSettings = @{ "fileUris" = (,"https://raw.githubusercontent.com/eoncu3841/EU-sample-webpage/main/eu-sample-webpage.ps1");  "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File eu-sample-webpage.ps1" }

Set-AzVMExtension -ResourceGroupName $eu_rgname `
    -ExtensionName "IIS" `
    -VMName $eu_web_vmname `
    -Location $eu_location `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -Settings $publicSettings `
    -verbose
    ##-SettingString '{"commandToExecute":"powershell Add-WindowsFeuture Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername) "}'


##### CReuTE MSSQL VM #####

# Initialze MSSQL ASG value

$eu_MSSQL_ASG_value = Get-AzApplicationSecurityGroup -Name $eu_MSSQL_ASG_Name -ResourceGroupName $eu_rgname

#Creute a Network Interface IP Configuration

$eu_MSSQL_ipconfig = New-AzNetworkInterfaceIpConfig `
-Name $eu_MSSQL_IPConfig_name  `
-SubnetId $eu_mssql_subnetid `
-ApplicationSecurityGroupId $eu_MSSQL_ASG_value.Id

# Creute the Network Interface

$eu_mssql_nic = New-AzNetworkInterface -Name $eu_MSSQL_NIC_name `
-ResourceGroupName $eu_rgname `
-Location $eu_location `
-IpConfiguration $eu_MSSQL_ipConfig


# Creute & Update VM properties

$eu_mssql_vmConfig = New-AzVMConfig -VMName $eu_mssql_vmname -VMSize $eu_mssql_VMSize 
$eu_mssql_vmConfig = Set-AzVMOperatingSystem -VM $eu_mssql_vmConfig -Windows -ComputerName $eu_mssql_vmname -Credential $eu_mssql_credentials -ProvisionVMAgent -EnableAutoUpdate
$eu_mssql_vmConfig = Add-AzVMNetworkInterface -VM $eu_mssql_vmConfig -Id $eu_mssql_nic.Id
$eu_mssql_vmConfig = Set-AzVMSourceImage -VM $eu_mssql_vmConfig -PublisherName "MicrosoftSQLServer" -Offer "SQL2017-WS2016" -Skus "SQLDEV" -Version "latest" 

#Creute VM for MSSQL

New-AzVM -ResourceGroupName $eu_rgname `
-Location $eu_location `
-VM $eu_mssql_vmConfig

