$filePath = ".\roleAssignments.csv"
$roleAssignments = New-Object System.Collections.Generic.List[System.Object]

$resourceGroupNames = Get-AzResourceGroup | Select-Object ResourceGroupName, Location, Tags

foreach($resourceGroup in $resourceGroupNames) {
    
    $rgInfo = [ordered]@{}
    $resourceList = New-Object System.Collections.Generic.List[System.Object]

    $rgInfo.Add("ResourceGroupName", $resourceGroup.ResourceGroupName);
    $rgInfo.Add("Location", $resourceGroup.Location);
    $rgInfo.Add("Tags", $resourceGroup.Tags);

    $resources = Get-AzResource -ResourceGroupName $resourceGroup.ResourceGroupName
    foreach($resource in $resources){
        
        $resourceInfo = [ordered]@{}
        $roleassignmentList = New-Object System.Collections.Generic.List[System.Object]

        $getRoleAssignments = Get-AzRoleAssignment -ResourceGroupName $resourceGroup.ResourceGroupName `
                                -ResourceName $resource.Name -ResourceType $resource.ResourceType
        
        $resourceInfo.Add("ResourceName", $resource.Name);
        $resourceInfo.Add("ResourceType", $resource.ResourceType);

        foreach($roleassignment in $getRoleAssignments){

            $roleAssignmentInfo = [ordered]@{}
            
            $roleAssignmentInfo.Add("RoleAssignmentName", $roleassignment.RoleAssignmentName);
            $roleAssignmentInfo.Add("RoleDefinitionName", $roleassignment.RoleDefinitionName);
            $roleAssignmentInfo.Add("Scope", $roleassignment.Scope);

            $result = Get-AzureADObjectByObjectId -ObjectIds $roleassignment.ObjectId

            $roleAssignmentInfo.Add("DisplayName", $result.DisplayName);

            $psCustomObject = [pscustomobject]$roleAssignmentInfo
            $roleassignmentList.Add($psCustomObject);
        }

        $resourceInfo.Add("RoleAssignmentList", $roleassignmentList);

        $psCustomObject = [pscustomobject]$resourceInfo
        $resourceList.Add($psCustomObject);
    }

    $rgInfo.Add("ResourceNamesList", $resourceList);

    $psCustomObject = [pscustomobject]$rgInfo
    $roleAssignments.Add($psCustomObject);
}

$roleAssignments | Export-Csv -Path $filePath -NoTypeInformation