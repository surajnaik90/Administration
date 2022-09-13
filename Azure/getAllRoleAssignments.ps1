#Script to get all the role assignments of Azure resource
# Script requires Azure AD module to be pre-installed along with Az PowerShell module

class RoleAssignment {
    [string]$ResourceGroupName
    [string]$Location
    [string]$Tags
    [string]$ResourceName
    [string]$ResourceType
    [string]$RoleAssignmentName
    [string]$RoleDefinitionName
    [string]$Scope
    [string]$DisplayName
}


$filePath = ".\roleAssignments.csv"
$roleAssignments = New-Object System.Collections.Generic.List[System.Object]

$resourceGroupNames = Get-AzResourceGroup | Select-Object ResourceGroupName, Location, Tags
foreach($resourceGroup in $resourceGroupNames) {

    $resources = Get-AzResource -ResourceGroupName $resourceGroup.ResourceGroupName
    foreach($resource in $resources){

        $getRoleAssignments = Get-AzRoleAssignment -ResourceGroupName $resourceGroup.ResourceGroupName `
                                -ResourceName $resource.Name -ResourceType $resource.ResourceType
        

        foreach($roleassignment in $getRoleAssignments){

            $result = Get-AzureADObjectByObjectId -ObjectIds $roleassignment.ObjectId

            $roleAssignmentInfo = [RoleAssignment]::new()
            

            $roleAssignmentInfo.ResourceGroupName = $resourceGroup.ResourceGroupName
            $roleAssignmentInfo.Location = $resourceGroup.Location
            
            $tags = [System.Text.StringBuilder]::new()
            foreach($tag in $resourceGroup.Tags.Keys) {
               
               $value = $resourceGroup.Tags[$tag]
                
               [void]$tags.Append($tag.Name)
            }
            
            $roleAssignmentInfo.Tags = $tags
            $roleAssignmentInfo.ResourceName = $resource.Name
            $roleAssignmentInfo.ResourceType = $resource.ResourceType
            $roleAssignmentInfo.RoleAssignmentName = $roleassignment.RoleAssignmentName
            $roleAssignmentInfo.RoleDefinitionName = $roleassignment.RoleDefinitionName
            $roleAssignmentInfo.Scope = $roleassignment.Scope
            $roleAssignmentInfo.DisplayName = $result.DisplayName

            $roleAssignments.Add($roleAssignmentInfo)
        }
    }
}

$roleAssignments | Export-Csv -Path $filePath -NoTypeInformation
