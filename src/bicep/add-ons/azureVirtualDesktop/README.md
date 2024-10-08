# Azure Virtual Desktop Solution

[**Home**](./README.md) | [**Features**](./docs/features.md) | [**Design**](./docs/design.md) | [**Prerequisites**](./docs/prerequisites.md) | [**Troubleshooting**](./docs/troubleshooting.md)

This solution will deploy a fully operational Azure Virtual Desktop (AVD) [stamp](https://learn.microsoft.com/azure/architecture/patterns/deployment-stamp) adhereing to the [Zero Trust principles](https://learn.microsoft.com/security/zero-trust/azure-infrastructure-avd). Many of the [common features](./docs/features.md) used with AVD have been automated in this solution for your convenience.

## Deployment Options

> [!WARNING]
> Failure to complete the [prerequisites](./docs/prerequisites.md) will result in an unsuccessful deployment.

### Blue Buttons

This option opens the deployment UI for the solution in the Azure Portal. Be sure to select the button for the correct cloud. If your desired cloud is not listed, please use the template spec option below.

[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fmissionlz%2Fmain%2Fsrc%2Fbicep%2Fadd-ons%2Fazure-virtual-desktop%2Fsolution.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fmissionlz%2Fmain%2Fsrc%2Fbicep%2Fadd-ons%2Fazure-virtual-desktop%2FuiDefinition.json)

### Template Spec

This option creates a template spec in Azure to deploy the solution and is the preferred option for air-gapped clouds. Once you create the template spec, open it in the portal and click the "Deploy" button.

````powershell
$Location = '<Azure Location>'
$ResourceGroupName = 'rg-ts-<Environment Abbreviation>-<Location Abbreviation>'
$TemplateSpecName = 'ts-avd-<Environment Abbreviation>-<Location Abbreviation>'

New-AzResourceGroup `
    -Name $ResourceGroupName `
    -Location $Location `
    -Force

New-AzTemplateSpec `
    -ResourceGroupName $ResourceGroupName `
    -Name $TemplateSpecName `
    -Version 1.0 `
    -Location $Location `
    -TemplateFile '.\src\bicep\add-ons\azure-virtual-desktop\solution.json' `
    -UIFormDefinitionFile '.\src\bicep\add-ons\azure-virtual-desktop\uiDefinition.json' `
    -Force
````
