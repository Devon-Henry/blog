
$global:managementGroupName = '' # Change this depending on environment requirements


New-AzManagementGroupDeployment -Location 'uksouth' `
    -Name '' ` # Add a deployment name shows under managementGroup>Deployments
    -TemplateFile './main.bicep' `
    -TemplateParameterFile './main.prod.bicepparam' `
    -ManagementGroupId $global:managementGroupName `
    -WhatIf

$userInput = Read-Host "WhatIf review | Do you want to continue with the actual deployment? type 'y' or 'n' "
if ($userInput -eq "y") {


New-AzManagementGroupDeployment -Location 'uksouth' `
    -Name '' ` # Add a deployment name shows under managementGroup>Deployments
    -TemplateFile './main.bicep' `
    -TemplateParameterFile './main.prod.bicepparam' `
    -ManagementGroupId $global:managementGroupName

}
else {
    Write-Host "Command cancelled." -ForegroundColor Red
}


