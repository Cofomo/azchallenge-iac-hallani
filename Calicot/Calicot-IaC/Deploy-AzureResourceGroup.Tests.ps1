Param(
    [string] $ResourceGroupName = "$env:AZURE_RG_NAME",
    [string] $ResourceGroupLocation = "$env:AZURE_RG_LOCATION"
)

BeforeAll {    
    $resources = Get-AzResource -ResourceGroupName $ResourceGroupName

    $deployParams = (Get-Content -Path '.\Calicot\Calicot-IaC\azuredeploy.parameters.json' | ConvertFrom-Json).parameters 

    function Get-ResourceDetails ([string]$Match, [string]$Type, [string]$Suffix = "") {
        $resource = $resources | Where-Object {$_.Name.Contains($Match) -and $_.Type.Equals($Type)}
        
        return Get-AzResource -ResourceId $resource.Id -ExpandProperties 
    }
}

Describe 'Azure Resources' {

    It 'Given resources list, it checks storage account' {

        $resourceDetails =  Get-ResourceDetails -Match "storage" -Type "Microsoft.Storage/storageAccounts" 

        $resourceDetails.Sku.Name | Should -Be $deployParams.storageAccountType.value
        $resourceDetails.Kind | Should -Be $deployParams.storageAccountKind.value
        $resourceDetails.Properties.AccessTier | Should -Be $deployParams.storageAccountAccessTier.value
    }

    It 'Given resources list, it checks function app hosting plan' {
        
        $resourceDetails =  Get-ResourceDetails -Match "ASP-functionapp" -Type "Microsoft.Web/serverFarms"

        $resourceDetails.Sku.Tier | Should -Be $deployParams.functionAppSku.value
        $resourceDetails.Sku.Size | Should -Be $deployParams.functionAppSkuCode.value
        $resourceDetails.Properties.Status | Should -Be "Ready"
    }

    It 'Given resources list, it checks function app' {
        
        $resourceDetails =  Get-ResourceDetails -Match "functionapp" -Type "Microsoft.Web/sites"

        $resourceDetails.Properties.Sku | Should -Be $deployParams.functionAppSku.value
        $resourceDetails.Properties.ServerFarmId | Should -Match "ASP-functionapp-"
        $resourceDetails.Properties.State | Should -Be "Running"
    }

    It 'Given resources list, it checks web app hosting plan' {
        
        $resourceDetails =  Get-ResourceDetails -Match "ASP-webapp" -Type "Microsoft.Web/serverFarms"

        $resourceDetails.Sku.Tier | Should -Be $deployParams.webAppSku.value
        $resourceDetails.Sku.Size | Should -Be $deployParams.webAppSkuCode.value
        $resourceDetails.Kind | Should -Be $deployParams.webAppKind.value
        $resourceDetails.Properties.Status | Should -Be "Ready"
    }

    It 'Given resources list, it checks web app' {
        
        $resourceDetails =  Get-ResourceDetails -Match "webapp" -Type "Microsoft.Web/sites"

        $resourceDetails.Properties.Sku | Should -Be $deployParams.webAppSku.value
        $resourceDetails.Properties.ServerFarmId | Should -Match "ASP-webapp-"
        $resourceDetails.Properties.State | Should -Be "Running"
    }

    It 'Given resources list, it checks SQL Server' {
        
        $resourceDetails =  Get-ResourceDetails -Match "sqlserver" -Type "Microsoft.Sql/servers" 

        $resourceDetails.Properties.State | Should -Be "Ready"
    }

    It 'Given resources list, it checks database' {
        
        $resourceDetails =  Get-ResourceDetails -Match "Calicot" -Type "Microsoft.Sql/servers/databases"

        $resourceDetails.Sku.Name | Should -Be $deployParams.databaseSkuName.value
        $resourceDetails.Sku.Tier | Should -Be $deployParams.databaseTier.value
        $resourceDetails.Sku.Capacity | Should -Be $deployParams.databaseCapacity.value
        $resourceDetails.Properties.Status | Should -Be "Online"
    }

    It 'Given resources list, it checks service bus' {
        
        $resourceDetails =  Get-ResourceDetails -Match "servicebus" -Type "Microsoft.ServiceBus/namespaces"

        $resourceDetails.Sku.Name | Should -Be $deployParams.servicebusTier.value
        #$resourceDetails.Sku.Capacity | Should -Be $deployParams.servicebusCapacity.value
        $resourceDetails.Properties.Status | Should -Be "Active"
    }

    It 'Given resources list, it checks all resources are deployed in the same location' {
   
        foreach($resource in $resources) {
            $resource.Location | Should -Be $ResourceGroupLocation
        }
    }
}