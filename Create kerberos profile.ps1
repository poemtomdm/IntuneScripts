Install-Module microsoft.graph
import-module microsoft.graph



<#  
    .NOTES
    ===========================================================================
     Created on:    30th July 2023
     Created by:    Tom MACHADO
     Organization:  Synapsys IT
     Filename:      Get-IntuneReports.ps1 ## to edit
    ===========================================================================
    .DESCRIPTION

Get every users who has an intune enrolled macos devices 
Check if user domain group for kerberos already exists
If it exists, the script does not create the configuration profile nor kerberos group
If the kerberos group does not exist, script do the following
	Create kerberos profile
	Create kerberos group in Entra
	Assign profile to kerberos group
	Add kerberos group to remove nomad group. Remove nomad group is targeted by a shell script which uninstall Nomad (usefull for transition)

Then for each enrolled user who has an enrolled mac
    Script adds each user to the proper kerberos domain group
    And remove the user from any other domain group which is different from the actual user domain

===========================================================================

    .IMPROVEMENTS

Do not try to add user to kerberos group if the user is already a member
Use single foreach or multiple scripts
Use functions

#>

#### It's a summary for end of the script ####
$summary = @{
    UsersProcessed       = 0
    GroupsCreated        = 0
    ConfigurationsCreated= 0
    UsersAddedToGroup    = 0
    UsersRemovedFromGroup= 0
}

$startTime = Get-Date ### usefull for summary

### login into graph api
Connect-MgGraph
$uri = 'https://graph.microsoft.com/beta/deviceManagement/managedDevices?$filter='
$filter = "operatingsystem eq 'macos'"
$url = "$uri$filter"
$query = Invoke-MgGraphRequest -Uri $url
$managedmacos = $query.value
$managedmacosnextlink = $managedmacos."@odata.nextLink"

 
While ($managedmacosnextlink -ne $Null) {
    $query = (Invoke-MgGraphRequest -Uri $managedmacosnextlink)
    $managedmacosnextlink = $query."@odata.nextLink"
    $managedmacos += $query.value
}


### this ppart is usefull for reporting only, you can export userid and userdomain into an external file ###
$list = $managedmacos.userid
$domains = @()
$domain = @()
$infoinarray = @()
foreach ($userid in $list) {
    $domain = invoke-mggraphrequest -uri https://graph.microsoft.com/beta/users/$userid -method get | select -expandproperty onpremisesdomainname -ErrorAction SilentlyContinue
    $domains = $domains + $domain
    $userinfo = "$userid $domain"
    $infoinarray = $infoinarray + $userinfo ## usefull for reporting, userid and domain in this table
}
### end of reporting ###

# remove duplicated domains from the list
$uniquedomains = $domains | select -Unique

#set the uri to create the Intune conf profile
$uri = 'https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations'

# For each domain, if the group is not created yet, script creates the conf, group and assign
foreach ($singledomain in $uniquedomains) {

    ## Need caps for domain Intune conf profile and group naming convention
    $capssingledomain = $singledomain.ToUpper()  
    ## We consider the following : if the group is already created, no need to run the script. IF the group is missing then the group is created and the conf is created
    ## Check if Kerberos group already exist
    $uri = 'https://graph.microsoft.com/v1.0/groups?$filter='
    $filter = "displayname eq 'ORG0000-SG-MAC-USR-KerberosExtension-$capssingledomain'"
    $group = Invoke-MgGraphRequest -Uri $uri$filter -Method GET
    $notexist = [string]::IsNullOrEmpty($group.value)
    if ($notexist -match "True") {
        ## if its empty, create the group and the conf, else is at the end of the script
        ## I use SD6460-a as owner
        $json = @"      
{
    "description": "Kerberos Token Group for Skynote Mac $singledomain",
    "displayName": "ORG0000-SG-MAC-USR-KerberosExtension-$capssingledomain",
    "groupTypes": [
      ],
    "mailEnabled": false,
    "mailNickname": "KerberosTokenSkynoteMac",
    "securityEnabled": true,
    "owners@odata.bind": [
      "https://graph.microsoft.com/v1.0/users/21506325-c19d-4670-9c3e-fddd3c87665d"
    ],
  }
"@
    try {
        Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/groups" -Method post -Body $json
        $summary.GroupsCreated++ ### Update the groups created variable for summary
    }
    catch {
        Write-Host "Error creating group for domain ORG0000-SG-MAC-USR-KerberosExtension-$capssingledomain"
    }
        ## group is created from here


        ## now lets create the conf

    $json = @"
    {
    "@odata.type": "#microsoft.graph.macOSDeviceFeaturesConfiguration",
    "description": null,
    "displayName": "ORG0000 - SUPPORT - Kerberos Token - $singledomain",
    "version": 1,
    "roleScopeTagIds": [
        "167"],
    "adminShowHostInfo": false,
    "loginWindowText": null,
    "authorizedUsersListHidden": false,
    "authorizedUsersListHideLocalUsers": false,
    "authorizedUsersListHideMobileAccounts": false,
    "authorizedUsersListIncludeNetworkUsers": false,
    "authorizedUsersListHideAdminUsers": false,
    "authorizedUsersListShowOtherManagedUsers": false,
    "shutDownDisabled": false,
    "restartDisabled": false,
    "sleepDisabled": false,
    "consoleAccessDisabled": false,
    "shutDownDisabledWhileLoggedIn": false,
    "restartDisabledWhileLoggedIn": false,
    "powerOffDisabledWhileLoggedIn": false,
    "logOutDisabledWhileLoggedIn": false,
    "screenLockDisableImmediate": false,
    "singleSignOnExtension": null,
    "contentCachingEnabled": false,
    "contentCachingType": "notConfigured",
    "contentCachingMaxSizeBytes": null,
    "contentCachingDataPath": null,
    "contentCachingDisableConnectionSharing": false,
    "contentCachingForceConnectionSharing": false,
    "contentCachingClientPolicy": "notConfigured",
    "contentCachingPeerPolicy": "notConfigured",
    "contentCachingParentSelectionPolicy": "notConfigured",
    "contentCachingParents": [],
    "contentCachingLogClientIdentities": false,
    "contentCachingBlockDeletion": false,
    "contentCachingShowAlerts": false,
    "contentCachingKeepAwake": false,
    "contentCachingPort": null,
    "airPrintDestinations": [],
    "autoLaunchItems": [],
    "associatedDomains": [],
    "appAssociatedDomains": [],
    "macOSSingleSignOnExtension": {
        "@odata.type": "#microsoft.graph.macOSKerberosSingleSignOnExtension",
        "realm": "$capssingledomain",
        "domains": [
            "$singledomain"
        ],
        "blockAutomaticLogin": false,
        "cacheName": null,
        "credentialBundleIdAccessControlList": [
            "com.trusourcelabs.NoMAD",
            "com.microsoft.edgemac",
            "com.apple.Safari",
            "com.apple.Ticket-Viewer",
            "com.apple.printcenter"
        ],
        "domainRealms": [],
        "isDefaultRealm": true,
        "passwordBlockModification": false,
        "passwordExpirationDays": null,
        "passwordExpirationNotificationDays": 30,
        "userPrincipalName": "{{onPremisesSamAccountName}}",
        "passwordRequireActiveDirectoryComplexity": true,
        "passwordPreviousPasswordBlockCount": null,
        "passwordMinimumLength": null,
        "passwordMinimumAgeDays": null,
        "passwordRequirementsDescription": null,
        "requireUserPresence": false,
        "activeDirectorySiteCode": null,
        "passwordEnableLocalSync": true,
        "blockActiveDirectorySiteAutoDiscovery": false,
        "passwordChangeUrl": null,
        "modeCredentialUsed": "kerberosDefault",
        "usernameLabelCustom": null,
        "userSetupDelayed": false,
        "signInHelpText": "Please enter your Engie password",
        "kerberosAppsInBundleIdACLIncluded": true,
        "managedAppsInBundleIdACLIncluded": false,
        "credentialsCacheMonitored": false,
        "preferredKDCs": [],
        "tlsForLDAPRequired": false
    },
    "contentCachingClientListenRanges": [],
    "contentCachingPeerListenRanges": [],
    "contentCachingPeerFilterRanges": [],
    "contentCachingPublicRanges": []
    }
"@
    $uri = 'https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations'
    # Create policy ACTION
    try {
        # Create policy ACTION
        Invoke-MgGraphRequest -Uri $uri -Body $json -Method POST -ContentType "application/json"
        $summary.ConfigurationsCreated++ ### Update the conf created variable for summary
    }
    catch {
        Write-Host "Error creating configuration ORG0000 - SUPPORT - Kerberos Token - $singledomain"
    }

    # Conf is created

    #now, let's assign the conf to the right newly created group
    #we find the conf created by its name kerberos-domainname
    $uri = 'https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?$filter='
    $filter = "displayname eq 'ORG0000 - SUPPORT - Kerberos Token - $singledomain'"
    $confkerberosid = Invoke-MgGraphRequest -Uri $uri$filter -Method get | select -ExpandProperty value | select -ExpandProperty id
    #get uri to assign the kerberos conf later on
    $uriassign = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$confkerberosid/assign"

    #get group id for the user domain
    $urigroup = 'https://graph.microsoft.com/beta/groups?$filter='
    $filtergroup = "displayname eq 'ORG0000-SG-MAC-USR-KerberosExtension-$capssingledomain'"
    $groupid = Invoke-MgGraphRequest -Uri $urigroup$filtergroup -Method get | select -ExpandProperty value | select -ExpandProperty id

    #assign group to the conf
    $uri = "$uriassign"
    $json = @"      
    { 
        "deviceConfigurationGroupAssignments": [ 
            {
            "@odata.type": "#microsoft.graph.deviceConfigurationGroupAssignment",
            "targetGroupId": "$groupid",
            }
        ] 
    } 
"@
    #Assign action
    Invoke-MgGraphRequest -Uri $uri -Body $json -Method POST -ContentType "application/json"



    ##### ajouter chaque groupe dans remove nomad group id = f72016eb-8d89-4c5f-a2e0-dd069395030a : 
    #this is the Remove Nomad Group id so Nomad is removed for the onboarded user. An Intune conf and shell script are targeted on this group
    $uri='https://graph.microsoft.com/v1.0/groups/f72016eb-8d89-4c5f-a2e0-dd069395030a/members/$ref'

    $json = @"      

  { 
    "@odata.id": "https://graph.microsoft.com/v1.0/groups/$groupid"

  } 
"@
    #ACTION TO ADD GROUP TO REMOVE NOMAD GROUP
    Invoke-MgGraphRequest -Uri $uri -Body $json -Method POST -ContentType "application/json"

}

    else {
        #if group is already created, then no need to create conf profile, end of script
        Write-Output "Group is already created, no need to run script"
    }

}



  foreach ($userid in $list) {
    $summary.UsersProcessed++ ### Update the user processed variable for summary
    $userinfo = invoke-mggraphrequest -uri https://graph.microsoft.com/beta/users/$userid -method get 
    $urigroup = 'https://graph.microsoft.com/beta/groups?$filter='
    $userdomain=$userinfo.onpremisesdomainname
    $filtergroup = "displayname eq 'ORG0000-SG-MAC-USR-KerberosExtension-$userdomain'"
    $groupid = Invoke-MgGraphRequest -Uri $urigroup$filtergroup -Method get | select -ExpandProperty value | select -ExpandProperty id
    $url="https://graph.microsoft.com/v1.0/groups/$groupid/members"
    $posturl='/$ref'

            $json = @"      
    
            {
                "@odata.id": "https://graph.microsoft.com/v1.0/directoryObjects/$userid"
            }
  }
"@

    try {
        Invoke-MgGraphRequest -Uri "$url$posturl" -Body $json -Method POST -ContentType "application/json"
        $summary.UsersAddedToGroup++
        Write-Output $userinfo.userPrincipalName
    }
    catch {
        Write-Host "Error adding user $userid to groupid $groupid"
    }

    $memberof = invoke-mggraphrequest -uri  "https://graph.microsoft.com/v1.0/users/$userid/memberOf"

    foreach ($groupmemberof in $memberof.value) {
        $groupname=$groupmemberof.displayname
            if ($groupname -like "*ORG0000-SG-MAC-USR-KerberosExtension*" -and $groupname -notlike "*$userdomain*") {
                Write-Output "$userid will be removed from $groupname" 

                $groupid = $groupmemberof.id
                $uri = "https://graph.microsoft.com/v1.0/groups/$groupid/members/$userid"
                $posturl ='/$ref'
                invoke-mggraphrequest -uri "$uri$posturl" -method delete
                $summary.UsersRemovedFromGroup++
                Write-Output "$userid is deleted from $groupname"
            }
    else {
        Write-Output $groupname
    }
    }

}

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "========================================"
Write-Host "   SCRIPT EXECUTION SUMMARY"
Write-Host "========================================"
Write-Host ("Start Time: " + $startTime.ToString())
Write-Host ("End Time: " + $endTime.ToString())
Write-Host ("Duration: " + $duration.ToString("hh\:mm\:ss"))
Write-Host "----------------------------------------"
Write-Host ("Total Users Processed: " + $summary.UsersProcessed)
Write-Host ("Total Groups Created: " + $summary.GroupsCreated)
Write-Host ("Total Configurations Created: " + $summary.ConfigurationsCreated)
Write-Host ("Total Users Added to Groups: " + $summary.UsersAddedToGroup)
Write-Host ("Total Users Removed from Groups: " + $summary.UsersRemovedFromGroup)
Write-Host "========================================"
