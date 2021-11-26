$param =@{
    server = "onPremServerName"
    onPremUser = "OnPrem username"
    onlineUser = "Online Username"
    folderPath = "path like c:\temp\"
    fileName = "name like users.txt"
    database = "onPrem DatabaseName"
    endpoint = "endpoint name like Hybrid Migration Endpoint - EWS (Default Web Site)"
    batchName = "batch migration name"
    deliveryDomain = "domain like contoso.onmicrosoft.com"
}

Import-Module ExchangeOnlineManagement

$onPremCredentials = Get-Credential -credential $param.onPremUser
$URL=$param.server
$ExOPSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$URL/PowerShell/ -Authentication Kerberos -Credential $onPremCredentials
Import-PSSession $ExOPSession

$users = Get-Content -Path $($param.folderpath + $param.fileName)
Add-Content -Path $($param.folderPath + "users.csv") -Value "EmailAddress"

foreach($user in $users) {
    Enable-Mailbox -Identity $user -Database $param.database
    Add-Content -Path $($param.folderPath + "users.csv") -Value $user
}
Remove-PSSession -Session $ExOPSession
Clear-Variable onPremCredential, URL, ExOPSession


$onlineCredential = Get-Credential -Credential $param.onlineUser
Connect-ExchangeOnline -Credential $onlineCredential

New-MigrationBatch -Name $param.batchName -SourceEndpoint $param.endpoint -TargetDeliveryDomain $param.deliveryDomain -CSVData ([System.IO.File]::ReadAllBytes("$($param.folderPath + "users.csv")")) -AutoStart -AutoComplete

Disconnect-ExchangeOnline -Confirm:$false
del $($param.folderPath + "users.csv")
Clear-Variable param, onPremCredential, onlineCredential, PSSession