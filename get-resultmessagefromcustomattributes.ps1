install-module microsoft.graph
Import-Module Microsoft.Graph

Connect-MgGraph

### Get the result from custom attributes
$procscript = Invoke-MgGraphRequest -Uri 'https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/1574edbd-6011-4329-92ae-caf9a239f8ca/deviceRunStates?$expand=managedDevice'
$proctype=$procscript.value
### For each result
foreach ($proc in $proctype){
    #Get intune device id
   $intuneid = $proc.managedDevice.id
    #get deviceid from azure
   $azureaddeviceid = Get-MgdeviceManagementManagedDevice -ManagedDeviceId $intuneid | select -expandproperty azureaddeviceid
   $quotedazureaddeviceid = "'$azureaddeviceid'" #single quote is necessary to be filtered
   $url = 'https://graph.microsoft.com/beta/devices?$filter=deviceid eq '
   $azureadobjectidrequest = Invoke-MgGraphRequest -uri $url$quotedazureaddeviceid #get object id from azure which is necessary to add device to group
   $azureadobjectid = $azureadobjectidrequest.value.id
   $params = @{
	"members@odata.bind" = @(
		"https://graph.microsoft.com/v1.0/directoryObjects/{$azureadobjectid}" #set param with object id
	)
}
# groupid to add device into is different depending on the result
if ($proc.resultMessage -match 'Apple') { 
    Update-MgGroup -GroupId '29b27d4c-e8bc-44b8-a374-8a26d7da29d8'-BodyParameter $params 
}
elseif($proc.resultMessage -match 'Intel') {
    Update-MgGroup -GroupId 'b9eba5aa-621a-41f6-b606-b625dde80e77'-BodyParameter $params
}
else {
    Write-Output "weird proc"
}
}

