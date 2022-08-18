#-----------------------------------------------------------------------------------------------------------------------------------
#Script: getApprovals.ps1
#
#Description: Script to retrieve all the pre-deployment approvals from all release pipelines of all the projects under Organization.           
#
#-----------------------------------------------------------------------------------------------------------------------------------

$filePath = ".\approvers.csv"

$organization = "org"
$personalAccessToken = "pattoken"
$base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($personalAccessToken)"))
$headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}

$orgURI = "https://vsrm.dev.azure.com/$($organization)/"
$projectsURI = "https://dev.azure.com/$($organization)/" + "_apis/projects"

#Retrieve all the projects
$projects = Invoke-RestMethod -Uri $projectsURI -Method Get -Headers $headers

$releaseDefApprovers = New-Object System.Collections.Generic.List[System.Object]
foreach($project in $projects.value) {

    $projectName = $project.name

    $releaseDefinitionsURI = $orgURI + "$($projectName)/_apis/release/definitions?api-version=7.1-preview.4"
    $releaseDefinitions = Invoke-RestMethod -Uri $releaseDefinitionsURI -Method Get -Headers $headers

    
    foreach($releaseDefinition in $releaseDefinitions.value) {

        $definitionID = $releaseDefinition.url.Split("/")[8]

        $defUri =  $orgURI + "$($projectName)/_apis/release/definitions/$($definitionID)?api-version=7.1-preview.4"
        $definitionInfo = Invoke-RestMethod -Uri $defUri -Method Get -Headers $headers

        $defInfo = [ordered]@{}

        $defInfo.Add("AccountName", $organization);
        $defInfo.Add("ProjectName", $projectName);
        $defInfo.Add("ReleaseDefinitionName", $definitionInfo.name);
        $defInfo.Add("ReleaseDefinitionURL", $definitionInfo.url);

        $approverNames = [System.Text.StringBuilder]::new()
        $approverIDs =  [System.Text.StringBuilder]::new()

        foreach($env in $definitionInfo.environments) {
            
            $envName = $env.name
            
            foreach($approval in $env.preDeployApprovals.approvals) {
                
                [void]$approverNames.Append($envName)
                [void]$approverNames.Append($approval.approver.displayName)
                [void]$approverNames.Append(";")
                [void]$approverIDs.Append($approval.approver.uniqueName)
                [void]$approverIDs.Append(";")
            }
        }

        $defInfo.Add("ApproverName", $approverNames.ToString());
        $defInfo.Add("ApproverID", $approverIDs.ToString());

        $psCustomObject = [pscustomobject]$defInfo
        $releaseDefApprovers.Add($psCustomObject);

        Write-Host $releaseDefinition.name
    }

}

$releaseDefApprovers | Export-Csv -Path $filePath -NoTypeInformation -Append
