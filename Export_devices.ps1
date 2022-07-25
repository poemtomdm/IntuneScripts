
install-module msal.ps
$thumbPrint = "YOUR-THUMBPRINT"

$authparams = @{
    ClientId    = 'idoftheapp'
    TenantId    = 'de55da9f-7c4c-44c6-8cbe-af4d0a0bfec0'
    Clientcert = Get-Item "Cert:\LocalMachine\My\$($thumbPrint)"
}


$auth = Get-MsalToken @authParams
$AccessToken = $Auth.AccessToken


$devices = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Auth.AccessToken)" } `
    -Uri  'https://graph.microsoft.com/v1.0/devices' `
    -Method Get

$devices.value
#full export of every devices, filter what you want to filter here