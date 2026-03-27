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
## change VNET NAME as you define in parameter file

$ea_vnet_name = "EAST-ASIA-VNET-01" 
$ea_vnet = Get-AzVirtualNetwork -ResourceGroupName $ea_rgname -Name $ea_vnet_name
  
### Store exisitng subnet value into variable ### 

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
   
