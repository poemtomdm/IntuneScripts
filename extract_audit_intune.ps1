# Populate with the App Registration details and Tenant ID
$appid = '8138dfa1-aa83-4c58-b65c-7cd1f27d7174'
$tenantid = 'de55da9f-7c4c-44c6-8cbe-af4d0a0bfec0'
$secret = 'secret'
 
$body =  @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $appid
    Client_Secret = $secret
}

$resourceid = "c94127be-ab3a-4f69-88bd-3aff5495187e" ### to edit
$daysbefore = 1 ### to edit


$connection = Invoke-RestMethod -Uri https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token -Method POST -Body $body
$token = $connection.access_token
Connect-MgGraph -AccessToken $token

$filter = (Get-Date).AddDays(-$daysbefore).ToString("yyyy-MM-dd")

$uri = 'https://graph.microsoft.com/beta/deviceManagement/auditEvents?$filter=activityDateTime gt '

$query = Invoke-MgGraphRequest -Uri $uri$filter -Method get
$events = $query.value

foreach ($event in $events) {

    if ($event.resources.resourceId -eq $resourceid) {

       $actor = $event.actor.userPrincipalName
       $when = $event.activityDateTime
       $name = $event.resources.displayName
       if ($event.activityOperationType -eq "Patch") {
            Write-Host "$name had been modified by $actor on $when"
       }
        elseif ($event.activityOperationType -eq "Delete") {
            Write-Host "$name had been deleted by $actor on $when"
        }
        elseif ($event.activityOperationType -eq "Post") {
            Write-Host "$name had been created by $actor on $when"
        }
}

}
