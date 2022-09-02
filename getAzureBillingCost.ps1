$resourceUrl="https://management.azure.com/"
$tenantId="tenant-Id"
$clientId="client-Id"
$clientSecret="client-secret"
$securedSecret = ConvertTo-SecureString $clientSecret -AsPlainText -Force

$pscredential = New-Object System.Management.Automation.PSCredential ($clientId, $securedSecret)

Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId
$context = Get-AzContext

$token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, `
$context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, $resourceUrl).AccessToken

$usageURL = "https://management.azure.com/subscriptions/{subscription-id}/providers/Microsoft.CostManagement/query?api-version=2021-10-01"

$header = @{
    'Authorization' = "Bearer $($token)"
    "Content-Type" = "application/json"
}
 
$body = '{
  "type": "Usage",
  "timeframe": "TheLastMonth",
  "dataset": {
    "granularity": "None",
    "aggregation": {
      "totalCost": {
        "name": "PreTaxCost",
        "function": "Sum"
      }
    },
    "grouping": [
      {
        "type": "Dimension",
        "name": "ResourceGroup"  #Change it to "MeterCategory" for resource level data
      }
    ]
  }
}'

#This line is necessary, else it will timeout by giving this issue:
#Invoke-RestMethod : The underlying connection was closed: An unexpected error occurred on a receive.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$UsageData = Invoke-RestMethod `
    -Method Post `
    -Uri $usageURL `
    -ContentType application/json `
    -Headers $header `
    -Body $body

$costReportData = New-Object System.Collections.Generic.List[System.Object]

foreach($costReport in $UsageData.properties.rows) {

    $costInfo = [ordered]@{}

    $costInfo.Add("Cost", $costReport[0]);
    $costInfo.Add("Resourcegroup", $costReport[1]);
    $costInfo.Add("Currency", $costReport[2]);

    $psCustomObject = [pscustomobject]$costInfo

    $ostReportData.Add($psCustomObject);
}

$costReportData | Export-Csv -Path $filePath -NoTypeInformation
