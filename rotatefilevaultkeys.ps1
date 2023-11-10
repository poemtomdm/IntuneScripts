

#### get devicesid
$devices = Get-Content -Path C:\Users\TomMACHADO.AzureAD\Downloads\deviceslist.txt
$uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
$macids = Get-IntuneManagedDevice | Get-MSGraphAllPages | Where-Object operatingSystem -eq macOS | select -ExpandProperty id

foreach ($id in $macids)
{

$rotateuri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$id/rotateFileVaultKey"
Invoke-RestMethod -Method post -Uri $rotateuri -Headers $token
}
