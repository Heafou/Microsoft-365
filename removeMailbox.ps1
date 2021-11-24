<#
Import users from txt file to remove their online mailbox in a hybrid deployment using licence Office 365 E3
Plan may change when using other O365 licence than E3
Just modify the param parameters to use it on your environment  
#>

Import-Module ExchangeOnlineManagement
Import-Module MSOnline

$param = @{
    username = "Enter UserPrincipalName"
    filePath = "Enter Path like c:\temp\"
    fileName = "Enter name like users.txt"
    plan = "EXCHANGE_S_ENTERPRISE"
}


$credential=Get-Credential -Credential $param.username
Connect-ExchangeOnline -Credential $credential
Connect-MsolService -Credential $credential

$users = Get-Content  $($param.filePath + $param.fileName)

$SkuIdName=Get-MsolAccountSku |where {$_.AccountSkuId -like "*ENTERPRISEPACK"} | select AccountSkuId 
$SkuId= $SkuIdName.AccountSkuId
$LO = New-MsolLicenseOptions -AccountSkuId $SkuId -DisabledPlans $param.plan
 
foreach($user in $users){ 
Set-MsolUserLicense -UserPrincipalName $user -LicenseOptions $LO
Set-User $user -PermanentlyClearPreviousMailboxInfo -confirm:$false
}