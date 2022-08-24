#-----------------------------------------------------------------------------------------------------------------------------------
#Script: getApprovals.ps1
#
#Description: Script to retrieve all the pre-deployment approvals from all release pipelines of all the projects under Organization.           
#
#-----------------------------------------------------------------------------------------------------------------------------------

$filePath = ".\approvers.csv"

$organization = "org"
$personalAccessToken = "pat-token"
$base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($personalAccessToken)"))
$headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}

$orgURI = "https://vsrm.dev.azure.com/$($organization)/"
$projectsURI = "https://dev.azure.com/$($organization)/" + "_apis/projects?api-version=6.0"

#Retrieve all the projects
$projects = Invoke-RestMethod -Uri $projectsURI -Method Get -Headers $headers

$releaseDefApprovers = New-Object System.Collections.Generic.List[System.Object]

$i=0
foreach($project in $projects.value) {

    $i= $i + 1
    $projectName = $project.name

    $releaseDefinitionsURI = $orgURI + "$($projectName)/_apis/release/definitions?api-version=7.1-preview.4"
    $releaseDefinitions = Invoke-RestMethod -Uri $releaseDefinitionsURI -Method Get -Headers $headers

    
    foreach($releaseDefinition in $releaseDefinitions.value) {

        $definitionID = $releaseDefinition.url.Split("/")[8]

        $defUri =  $orgURI + "$($projectName)/_apis/release/definitions/$($definitionID)?api-version=7.1-preview.4"
        $definitionInfo = Invoke-RestMethod -Uri $defUri -Method Get -Headers $headers

        $releaseUri = $orgURI + "$($projectName)/_apis/release/releases?definitionId=$($definitionID)&api-version=7.1-preview.8"
        $releasesInfo = Invoke-RestMethod -Uri $releaseUri -Method Get -Headers $headers

        $reason = [string]::Empty
        foreach($release in $releasesInfo.value) {
            $reason = $release.reason
            break
        }

        $defInfo = [ordered]@{}

        $defInfo.Add("AccountName", $organization);
        $defInfo.Add("ProjectName", $projectName);
        $defInfo.Add("ReleaseDefinitionName", $definitionInfo.name);

        $approverNames = [System.Text.StringBuilder]::new()
        $approverIDs =  [System.Text.StringBuilder]::new()

        foreach($env in $definitionInfo.environments) {
            
            foreach($approval in $env.preDeployApprovals.approvals) {
                
                [void]$approverNames.Append($approval.approver.displayName)
            }
        }

        $defInfo.Add("ApproverName", $approverNames.ToString());
        $defInfo.Add("TriggerType", $reason);

        $psCustomObject = [pscustomobject]$defInfo
        $releaseDefApprovers.Add($psCustomObject);

        Write-Host $releaseDefinition.name
    }

    Write-Progress -Activity "Search in Progress" -Status "$i% Complete:" -PercentComplete $i
}

$releaseDefApprovers | Export-Csv -Path $filePath -NoTypeInformation
