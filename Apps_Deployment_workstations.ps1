
### module to get the authenth token and tenant/client ids
install-module msal.ps
$clientid = "idoftheregisteredapp"
$tenantid = "de55da9f-7c4c-44c6-8cbe-af4d0a0bfec0"

$thumbPrint = "YOUR-THUMBPRINT"
$ClientCertificate = Get-Item "Cert:\LocalMachine\My\$($thumbPrint)"
$myAccessToken = Get-MsalToken -ClientId $clientID -TenantId $tenantID -ClientCertificate $ClientCertificate

$AccessToken = $myaccesstoken.AccessToken

#use the token
$Headers     = @{
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer $($AccessToken)"
}

#use the api containing the application
$appsfromgraph = 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps'
#call the API
$apps = Invoke-RestMethod -Method get -Uri $appsfromgraph -Headers $Headers
$appsvalue = $apps.value 
#get the workstations app
$win32 = $appsvalue | Where-Object "@odata.type" -Match '#microsoft.graph.win32LobApp'
$storeapp = $appsvalue | Where-Object "@odata.type" -Match '#microsoft.graph.microsoftStoreForBusinessApp'
$winget = $appsvalue | Where-Object "@odata.type" -Match '#microsoft.graph.winGetApp'
$lobapp = $appsvalue | Where-Object "@odata.type" -Match '#microsoft.graph.windowsMobileMSI'
$weblink = $appsvalue | Where-Object "@odata.type" -Match '#microsoft.graph.windowsWebApp'

$wksapps = $win32 + $storeapp + $winget + $lobapp + $weblink


#for each app, find me the deployment status on each device
foreach ($app in $wksapps) {
    $name = $app.displayname
    $id = $app.id
    $uri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/$id/deviceStatuses"
    $deployment = Invoke-RestMethod -Method get -Uri $uri -Headers $Headers
    Write-Output $deployment.value | ConvertTo-Csv | Out-File -FilePath ".\$name.csv"
}