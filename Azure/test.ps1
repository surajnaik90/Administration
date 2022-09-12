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

$roleAssignment1 = [RoleAssignment]::new()
$roleAssignment1.scope = "scope1"
$roleAssignment1.displayName = "displayName1"

$roleAssignment2 = [RoleAssignment]::new()
$roleAssignment2.scope = "scope2"
$roleAssignment2.displayName = "displayName2"

$roleAssignments = New-Object System.Collections.Generic.List[System.Object]
$roleAssignments.Add($roleAssignment1)
$roleAssignments.Add($roleAssignment2)


$roleAssignments | Export-Csv -Path .\testdata.csv -NoTypeInformation
