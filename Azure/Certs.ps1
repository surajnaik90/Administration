$currentDate = Get-Date
$endDate = $currentDate.AddYears(1)
$notAfter = $endDate.AddYears(1)
$pwd = "admin123"

$thumb = (New-SelfSignedCertificate -CertStoreLocation cert:\localmachine\my -DnsName com.foo.bar `
 -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter).Thumbprint

$pwd = ConvertTo-SecureString -String $pwd -Force -AsPlainText

Export-PfxCertificate -cert "cert:\localmachine\my\$thumb" -FilePath c:\temp\cert.pfx -Password $pwd


$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate("C:\temp\cert.pfx", $pwd)

$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())


$application = New-AzureADApplication -DisplayName "Azure Role Assignments Audit Service  Principal" -IdentifierUris "https://auditprincipal"

New-AzureADApplicationKeyCredential -ObjectId $application.ObjectId -CustomKeyIdentifier "auditprincipal" `
-StartDate $currentDate -EndDate $endDate -Type AsymmetricX509Cert -Usage Verify -Value $keyValue


$sp=New-AzureADServicePrincipal -AppId $application.AppId


$tenant=Get-AzureADTenantDetail


Add-AzureADDirectoryRoleMember -ObjectId $tenant.ObjectId -RefObjectId $sp.ObjectId

Write-Host "Tenant ID: " $tenant.ObjectId
Write-Host "Application ID: " $sp.AppId
Write-Host "Thumbprint: " $thumb

Connect-AzureAD -TenantId $tenant.ObjectId -ApplicationId  $sp.AppId -CertificateThumbprint $thumb