
#THEN, install GRAPH MODULE
Write-host "Installing Graph Module"
#install-module microsoft.graph -Force -ErrorAction SilentlyContinue -InformationAction SilentlyContinue -ErrorVariable trash -InformationVariable infotrash
import-module microsoft.graph -Force -ErrorAction SilentlyContinue -InformationAction SilentlyContinue -InformationVariable infotrash 

#AUTHENTICATE WITH WEB PAGE
Write-host "Please enter your admin credentials to authenticate into Graph API"
Connect-MgGraph
$groupsuri = 'https://graph.microsoft.com/v1.0/groups?$filter=displayname eq '
$namefilter = "'$groupname'"
Write-Host "Searching for $groupname id"
$group = Invoke-MgGraphRequest -Uri "$groupsuri$namefilter" -method get
$groupid = $group.value.id
Write-host "$groupname id is $groupid"

switch ($category) {

APPS {

### APPS PART
[System.Windows.Forms.MessageBox]::Show("APPS","You chose APPS")
$uri = 'https://graph.microsoft.com/beta/deviceappmanagement/mobileapps?$expand=assignments'
Write-Host "Gathering every apps in Intune you have access to"
$assignments = Invoke-MgGraphRequest -Uri $uri -method get 
$allapps = $assignments.value 
$allappsnextlink = $assignments."@odata.nextLink"
Write-Host "Counting how many apps you have access to"
while ($allappsnextlink -ne $null){
    $allappsresponse = (Invoke-MgGraphRequest -Uri $allappsnextlink -method get)
    $allappsnextlink = $allappsresponse."@odata.nextLink"
    $allapps += $allappsresponse.value
    }
    Write-Host Parsing the $allapps.count apps
    $appstargeted = ""
    $appstargeted = $appstargeted.ToString()
    Write-Host "Parsing which apps are targeted to $groupname"
    ForEach ($app in $allapps) {
        if ($app.assignments.target.groupid -eq $groupid) { 
         $appname = $app.displayName
        $searchintent = $app.assignments | Where-Object id -like "*$groupid*"
         $intent = $searchintent.intent
         $appstargeted = "$appstargeted" + "$appname is targetted as $intent" | ft -HideTableHeaders | Out-String
     }
 }
 
Write-Host $appstargeted
}

### CONF PART ###
CONFS {
[System.Windows.Forms.MessageBox]::Show("CONFS","You chose CONFS")
$uri = 'https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?$expand=assignments'
Write-Host "Gathering every configuration profiles in Intune you have access to"
$assignments = Invoke-MgGraphRequest -Uri $uri -method get 
$allconfs = $assignments.value 
$allconfsnextlink = $assignments."@odata.nextLink"
Write-Host "Counting how many confs you have access to"
while ($allconfsnextlink -ne $null){
    $allconfsresponse = (Invoke-MgGraphRequest -Uri $allconfsnextlink -method get)
    $allconfsnextlink = $allconfsresponse."@odata.nextLink"
    $allconfs += $allconfsresponse.value
    }
    Write-Host Parsing the $allconfs.count confs
    $confstargeted = ""
    $confstargeted = $confstargeted.ToString()
    Write-Host "Parsing which confs are targeted to $groupname"
    ForEach ($conf in $allconfs) {
        if ($conf.assignments.target.groupid -eq $groupid) { 
         $confname = $conf.displayName
         $searchintent = $conf.assignments | Where-Object id -like "*$groupid*"
         $intent = $searchintent.intent
         $confstargeted = "$confstargeted" + "$confname is targetted as $intent" | ft -HideTableHeaders | Out-String
     }
 }
 
Write-Host $confstargeted
}

}



