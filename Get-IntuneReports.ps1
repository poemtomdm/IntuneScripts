Install-Module microsoft.graph
import-module microsoft.graph

<#	
	.NOTES
	===========================================================================
	 Created on:   	19th september 2023
	 Created by:   	Tom MACHADO
	 Organization: 	Synapsys IT
	 Filename:     	Get-IntuneReports.ps1
	===========================================================================
	.DESCRIPTION
		The script use a registered application permissions to get api results on Intune :
        - It connects to Intune tenant
        - It gets every enrolled devices
        - For each device it 
            - get the application deployment status
            - export deployment status, device name and user upn into json file
        
        We assume the registered application has sufficient permissions to perform get api calls
	===========================================================================
    .IMPROVEMENTS
        Client must change registered app id, tenant id, secret and jsonfilepath
        Client can use a certificate instead of secret (preferred)
        Client can export any device info using $device inside the foreach loop
        Client might prefere another json export format with compress or other parameters (export-json instead of convert-json)
#>

# Populate with App Registered ID and Tenant ID
$appid = '8138dfa1-aa83-4c58-b65c-7cd1f27d7174'
$tenantid = 'de55da9f-7c4c-44c6-8cbe-af4d0a0bfec0'
$secret = 'your secret, located wherever you want'
$jsonFilePath = '/Users/tommachado/Downloads/deploy.json'
 
$body =  @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $appid
    Client_Secret = $secret
}

$connection = Invoke-RestMethod -Uri https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token -Method POST -Body $body
$token = $connection.access_token
Connect-MgGraph -AccessToken $token

## get devices ##
$uri = "https://graph.microsoft.com/beta/devicemanagement/manageddevices"
$devices = Invoke-MgGraphRequest -method get -uri $uri
$devicesinfo = $devices.value ## can be exported

## get app deployment for each device : get user id, then build the uri to get app info
    # you can also export any device info. Currently, onlt devicename and upn are exported. All device info are under $device inside the loop
foreach ($device in $devicesinfo) {

    $userid = $device.userid
    $intunedeviceid = $device.id
    $upn = $device.userPrincipalName ## to export
    $devicename = $device.deviceName ## to export
    $uri = "https://graph.microsoft.com/beta/users('$userid')/mobileAppIntentAndStates('$intunedeviceid')"
    $apps = Invoke-MgGraphRequest -Uri $uri -method get
    $appstatusdeployment = $apps.mobileAppList ## to export
    ## create pscustomobject with every variables to export
    $exportvar = @(
        [PSCustomObject]@{
        upn = $upn
        devicename = $devicename
        appsdeploymentstatus = $appstatusdeployment
    } 
    )
    $jsonobject = $exportvar | ConvertTo-Json -depth 10
    $jsonArray += $jsonObject
}

ConvertTo-Json $jsonArray | add-content -Path $jsonFilePath #json export to improve with the Client's preferences (compress or export-json cmdlet) to have a suitable format