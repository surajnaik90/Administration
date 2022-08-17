#-------------------------------------------------------------------------------------------------------------------------
#Script: GetAllPipelinesTriggerTimings.ps1
#
#Description: Script generates the info of all project pipeline triggers in a PROD subscription across streams in a CSV format.           
#
#-------------------------------------------------------------------------------------------------------------------------
#Pre-requisites to run this script:
#
#                 OS: Windows 10 
# PowerShell version: 5.1 & above 
#      Az PowerShell: 6.2.1 
#                     Install from here: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-6.2.1
#
# After Az PowerShell installation, please configure PS environment by running below 2 commands individually:
#                a. Connect-AzAccount
#                b.	Set-AzContext -Subscription "sub-id"         
#
#
# 
#-------------------------------------------------------------------------------------------------------------------------


$filePath = ".\triggers.csv"
$resourceGroup = "bieno-da05-p-80010-rg"

if (Test-Path $filePath) {

    Remove-Item $filePath

    write-host "$filePath has been deleted"
}

$triggers = New-Object System.Collections.Generic.List[System.Object]
$datafactories = Get-AzDataFactoryV2 -ResourceGroupName $resourceGroup

foreach($datafactory in $datafactories) {

    Write-Host "Retrieving all trigger details for " $datafactory.DataFactoryName

    $res = Get-AzDataFactoryV2Trigger -ResourceGroupName $resourceGroup -DataFactoryName $datafactory.DataFactoryName

    
    foreach($item in $res) {
 
        if($item -ne $null) {

            Write-Host "Retrieving all trigger details for " $item.Name
        
            $triggerInfo = [ordered]@{}

            $triggerInfo.Add("TriggerName", $item.Name);
            $triggerInfo.Add("ResourceGroupName", $item.ResourceGroupName);
            $triggerInfo.Add("DataFactoryName", $item.DataFactoryName);
            $triggerInfo.Add("RuntimeState", $item.RuntimeState);
            $triggerInfo.Add("Frequency", $item.Properties.Recurrence.Frequency);
            $triggerInfo.Add("Interval", $item.Properties.Recurrence.Interval);
            $triggerInfo.Add("TimeZone", $item.Properties.Recurrence.TimeZone);

            if($item.Properties.Events -ne $null) {
                $triggerInfo.Add("EventType", $item.Properties.Events[0]);
                $triggerInfo.Add("BlobPathBeginsWith", $item.Properties.BlobPathBeginsWith);
                $triggerInfo.Add("Scope", $item.Properties.Scope);
            }
            else {
                $triggerInfo.Add("EventType", "Schedule based trigger");
            }

            if( $item.Properties.Recurrence.Schedule.Hours -ne $null) {
                $triggerInfo.Add("Hours", $item.Properties.Recurrence.Schedule.Hours.Item(0));
            } else { $triggerInfo.Add("Hours", "00" ); }

            if( $item.Properties.Recurrence.Schedule.Minutes -ne $null) {
                $triggerInfo.Add("Minutes", $item.Properties.Recurrence.Schedule.Minutes.Item(0));
            } else { $triggerInfo.Add("Minutes", "00" ); }

            $pipelines = New-Object System.Collections.Generic.List[System.Object]
            
            if($item.Properties.Pipelines -ne $null) {

                $pipelinesCount = $item.Properties.Pipelines.Count
                for($i=0; $i -lt $pipelinesCount; $i++) {

                    $pipelines.Add($item.Properties.Pipelines[$i].PipelineReference.ReferenceName);
                }
                $triggerInfo.Add("Pipelines", $pipelines);
            }

            $customObject = [pscustomobject]$triggerInfo

            $triggers.Add($customObject);

            Write-Host "Done : Retrieving all triger details for " $item.Name
        }    
    }

    $pipelineTriggers = New-Object System.Collections.Generic.List[System.Object]
    
    foreach($trigger in $triggers) {

         foreach($pipeline in $trigger.Pipelines) {
            
            $pipelineInfo = [ordered]@{}

            $pipelineInfo.Add("PipelineName", $pipeline);
            $pipelineInfo.Add("TriggerName", $trigger.TriggerName);
            $pipelineInfo.Add("EventType", $trigger.EventType);
            $pipelineInfo.Add("BlobPathBeginsWith", $trigger.BlobPathBeginsWith);
            $pipelineInfo.Add("Scope", $trigger.Scope);
            $pipelineInfo.Add("DataFactoryName", $trigger.DataFactoryName);            
            $pipelineInfo.Add("Hours", $trigger.Hours);
            $pipelineInfo.Add("Minutes", $trigger.Minutes);
            $pipelineInfo.Add("TimeZone", $trigger.TimeZone);
            $pipelineInfo.Add("TriggerState", $trigger.RuntimeState);
            $pipelineInfo.Add("ResourceGroupName", $trigger.ResourceGroupName);
            $pipelineInfo.Add("Frequency", $trigger.Frequency);
            $pipelineInfo.Add("Interval", $trigger.Interval);

            $psCustomObject = [pscustomobject]$pipelineInfo

            $pipelineTriggers.Add($psCustomObject);
             
         }
    }

    Write-Host "Done: Retrieving all trigger details for " $datafactory.DataFactoryName
    
}

$pipelineTriggers | Export-Csv -Path $filePath -NoTypeInformation -Append
