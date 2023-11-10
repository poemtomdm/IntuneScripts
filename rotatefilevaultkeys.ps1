Install-Module microsoft.graph.intune
Import-Module Microsoft.Graph.Intune

Connect-MSGraph

Get-Command -Module microsoft.graph.intune | fl | Out-File C:\Users\TomMACHADO.AzureAD\Downloads\foo.txt


<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: Get-GraphExportApiReport
Description:
Get an CSV Report from the Graph API
Release notes:
Version 1.0: Init
#>

function Get-AuthToken {
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        $User
    )

    $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
    $tenant = $userUpn.Host
    $AadModule = Get-Module -Name "AzureAD" -ListAvailable
    if ($AadModule -eq $null) {
        Write-Host "AzureAD PowerShell module not found, looking for AzureADPreview"
        $AadModule = Get-Module -Name "AzureADPreview" -ListAvailable
    }

    $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"

    Add-Type -Path $adal -ErrorAction SilentlyContinue
    Add-Type -Path $adalforms -ErrorAction SilentlyContinue
    $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    $resourceAppIdURI = "https://graph.microsoft.com"
    $authority = "https://login.microsoftonline.com/$Tenant"

    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
    $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
    $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($User, "OptionalDisplayableId")
    $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI,$clientId,$redirectUri,$platformParameters,$userId).Result

      
    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'="Bearer " + $authResult.AccessToken
        'ExpiresOn'=$authResult.ExpiresOn
        }

    return $authHeader
}

#################################################################################################
########################################### Start ###############################################
#################################################################################################
$reportName = 'DetectedAppsRawData'

#Get auth toke
if(-not $global:authToken.Authorization){
    if($User -eq $null -or $User -eq ""){
    $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
    Write-Host
    }
    $global:authToken = Get-AuthToken -User $User
}

$token = Get-AuthToken -User $User

#### get devicesid
$devices = Get-Content -Path C:\Users\TomMACHADO.AzureAD\Downloads\deviceslist.txt
$uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
$macids = Get-IntuneManagedDevice | Get-MSGraphAllPages | Where-Object operatingSystem -eq macOS | select -ExpandProperty id

foreach ($id in $macids)
{

$rotateuri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$id/rotateFileVaultKey"
Invoke-RestMethod -Method post -Uri $rotateuri -Headers $token
}





/Applications/Parallels\ Desktop.app/Contents/MacOS/prl_macvm_create ~/Downloads/UniversalMac_13.0.1_22A400_Restore.ipsw ~/Parallels/macOS.macvm --disksize 80000000000

