### module to get the authenth token
install-module msal.ps
$clientid = "idoftheregisteredapp"
$tenantid = "de55da9f-7c4c-44c6-8cbe-af4d0a0bfec0"
$deviceid = "PUT YOUR DEVICE INTUNE ID"


$thumbPrint = "23283D10A8BA03C304295BBF43AFCF098172BF66"
$ClientCertificate = Get-Item "Cert:\LocalMachine\My\$($thumbPrint)"
$myAccessToken = Get-MsalToken -ClientId $clientID -TenantId $tenantID -ClientCertificate $ClientCertificate


$AccessToken = $myaccesstoken.AccessToken

#use the token
$Headers     = @{
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer $($AccessToken)"
}


$locatedeviceuri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$deviceid/locateDevice"
Invoke-RestMethod -Method Post -Uri $locatedeviceuri -Headers $Headers
$syncuri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$deviceid/syncDevice"
invoke-RestMethod -Method Post -Uri $syncuri -Headers $Headers

#You can improve the waiting process by requesting the result message for example or create a loop
Write-Output "Waiting the device to be located"
Start-Sleep -Seconds 60
Write-Output "Waiting the device to be located"
Start-Sleep -Seconds 60
Write-Output "Waiting the device to be located"
Start-Sleep -Seconds 60
Write-Output "Waiting the device to be located"
Start-Sleep -Seconds 60
Write-Output "Waiting the device to be located"
Start-Sleep -Seconds 60


$locationuriresults = "https://graph.microsoft.com/beta/deviceManagement/manageddevices/$id"
$select = '?$select=deviceActionResults'
$location = Invoke-RestMethod -Method Post -Uri $locationuriresults$select -Headers $Headers


$longitude = $location.deviceactionresults.devicelocation.longitude
$latitude = $location.deviceactionresults.devicelocation.latitude

$longitudeformat = $longitude -replace ',','.'
$latitudeformat = $latitude -replace ',','.'

$url = "https://www.itilog.com/fr/gps/$longitudeformat/$latitudeformat"
Start-Process -FilePath $url


