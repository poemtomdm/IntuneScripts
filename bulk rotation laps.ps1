#Replace this id by your targeted groupid
$groupid = "fbca4062-9d7c-49e5-84a5-10d9927f3922" 

# use certificate to authenticate on GRAPH
Connect-MgGraph -ClientId 8138dfa1-aa83-4c58-b65c-7cd1f27d7174 -TenantId de55da9f-7c4c-44c6-8cbe-af4d0a0bfec0 -CertificateThumbprint BB2B8F206FAE8D3A03E71AA4A652C9DB6A6C5E2E

#get every members of group containing devices in Entra where id is the groupid
$uri = "https://graph.microsoft.com/v1.0/groups/$groupid/members"
$devices = Invoke-MgGraphRequest -method get -uri $uri

#get only the AzureDeviceId
$azuredeviceids=$devices.value.deviceid

#for each AzureAdDeviceid
foreach ($intunedevice in $azuredeviceids) {

    #search for intunedeviceid
    $uri='https://graph.microsoft.com/beta/deviceManagement/managedDevices?$filter='
    $filter="azureADDeviceId eq '$intunedevice'"
    $intunedeviceinfo = Invoke-MgGraphRequest -method get -uri "$uri$filter"
    $intunedeviceid=$intunedeviceinfo.value.id

    #rotate action using the intunedeviceid
    $rotateuri="https://graph.microsoft.com/beta/deviceManagement/managedDevices/$intunedeviceid/rotateLocalAdminPassword"
    $rotateaction = Invoke-MgGraphRequest -Method POST -Uri $rotateuri

    #initiate a sync from Intune using the intunedeviceid
    $syncuri="https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$intunedeviceid/syncDevice"
    $syncaction = Invoke-MgGraphRequest -Method POST -Uri $syncuri
 
}
