# This script illustrate that to create vNet with three subnet in one particular location

# Connect to your Azure Subscription

$subscription_id = "99be1db5-4f4a-4f12-9bb7-fc76e26d9a2e" 
Connect-AzAccount -Subscription $subscription_id

# Create a new ResourceGroup

$eu_location = "East US"
$eu_rgname = "EAST-US-RG"
New-AzResourceGroup `
  -Name $eu_rgname `
  -Location $eu_location

# Provide ARM template file path and parameterFile path for vNet

$eu_vnet_templateFile = "D:\Personal\EMINE AZURE\Deliverables\ARM_TEMPLATES\EAST US\vNet-Subnet\EUS_vNet.json"
$eu_vnet_parameterFile= "D:\Personal\EMINE AZURE\Deliverables\ARM_TEMPLATES\EAST US\vNet-Subnet\EUS_vNet.parameters.json"
 
# Create a vnet in azure using AzResourceGroupDeployment

New-AzResourceGroupDeployment `
  -Name EU-VNET-SUBNET `
  -ResourceGroupName $eu_rgname `
  -TemplateFile $eu_vnet_templateFile `
  -TemplateParameterFile $eu_vnet_parameterFile
  

##### CREATE ASG & NSG AND ASSOCIATE NSG WITH SUBNET #####

#Provide ARM template file path and parameterFile path for ASG

$eu_asg_templateFile = "D:\Personal\EMINE AZURE\Deliverables\ARM_TEMPLATES\EAST US\ASG\ASG.json"
$eu_asg_parameterFile= "D:\Personal\EMINE AZURE\Deliverables\ARM_TEMPLATES\EAST US\ASG\ASG.parameters.json"

# Create a ASG in azure using AzResourceGroupDeployment

New-AzResourceGroupDeployment `
  -Name EA-ASG `
  -ResourceGroupName $eu_rgname `
  -TemplateFile $eu_asg_templateFile `
  -TemplateParameterFile $eu_asg_parameterFile

# Provide ARM template file path and parameterFile path for NSG

$eu_nsg_templateFile = "D:\Personal\EMINE AZURE\Deliverables\ARM_TEMPLATES\EAST US\NSG-Rules\East_US_NSG_Security_Rule.json"
$eu_nsg_parameterFile= "D:\Personal\EMINE AZURE\Deliverables\ARM_TEMPLATES\EAST US\NSG-Rules\East_US_NSG_Security_Rule.Parameters.json"

# Create NSG with security rule using deployment

New-AzResourceGroupDeployment `
  -Name EU-NSG-RULES `
  -ResourceGroupName $eu_rgname `
  -TemplateFile $eu_nsg_templateFile `
  -TemplateParameterFile $eu_nsg_parameterFile

### Retrieve exisitng vNet configuration ###


$eu_vnet_name = "EAST-US-VNET-01" 
$eu_vnet = Get-AzVirtualNetwork -ResourceGroupName $eu_rgname -Name $eu_vnet_name
  
### Store exisitng subnet value into variable ### 
## Subnet added into variable, so change it when require

  $eu_snet_web_name = "EAST-US-WEB-SUBNET"  
  $eu_snet_DMZ_name = "EAST-US-DMZ-SUBNET"
  $eu_snet_DB_name = "EAST-US-Database-SUBNET"

  $eu_subnet_DMZ = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $eu_vnet -Name $eu_snet_DMZ_name
  $eu_subnet_WEB = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $eu_vnet -Name $eu_snet_web_name
  $eu_subnet_DB = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $eu_vnet -Name $eu_snet_DB_name
  
### Retrieve Updated NSG information ###

  $eu_nsg_name = "EAST-US-NSG-01"
  $eu_nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $eu_rgname -Name $eu_nsg_name 
  
### Associate subnet with NSG ###
   $eu_subnet_DMZ.NetworkSecurityGroup = $eu_nsg
   $eu_subnet_WEB.NetworkSecurityGroup = $eu_nsg
   $eu_subnet_DB.NetworkSecurityGroup = $eu_nsg
   
### Update Existig vNET ### 
   Set-AzVirtualNetwork -VirtualNetwork $eu_vnet
   
