Get-AzureSubscription
Switch-AzureMode AzureResourceManager -Verbose
$Subscription = Select-AzureSubscription -SubscriptionName Azure-pas
Get-a


# Step 1

$TemplateParameterFile = 'C:\Users\saxouser\Documents\GitHub\azure-arm-hol\step01-create-a-virtual-machine-part1\begin\vm.param.json' 
$TemplateFile = 'C:\Users\saxouser\Documents\GitHub\azure-arm-hol\step01-create-a-virtual-machine-part1\complete\vm.json'

$Parms = @{ 'Name' = 'AzureTestZaggai'
            'TemplateParameterFile' = $TemplateParameterFile
            'Location' = 'westeurope'
            'TemplateFile' = $TemplateFile
          }

New-AzureResourceGroup @Parms             


$TemplateParameterFile = 'C:\Users\saxouser\Documents\GitHub\azure-arm-hol\step04-setup-iis-with-dsc\begin\vm.param.json' 
$TemplateFile = 'C:\Users\saxouser\Documents\GitHub\azure-arm-hol\step04-setup-iis-with-dsc\complete\vm.json'

$Parms = @{ 'Name' = 'AzureTestZaggai'
            'TemplateParameterFile' = $TemplateParameterFile
            'Location' = 'westeurope'
            'TemplateFile' = $TemplateFile
          }

New-AzureResourceGroup @Parms -Verbose -Force            
