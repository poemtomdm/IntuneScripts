[CmdletBinding()]
param (
    [string] $groupname = (Read-Host 'Enter the group name')
)

### COMMON PART ####

###INTERFACE FIRST####

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

# Set the size of your form
$Form = New-Object System.Windows.Forms.Form
$Form.width = 700
$Form.height = 500
$Form.Text = "Whats is targeted"

# Set the font of the text to be used within the form
$Font = New-Object System.Drawing.Font("Times New Roman",12)
$Form.Font = $Font

# Create a group that will contain your radio buttons
$MyGroupBox = New-Object System.Windows.Forms.GroupBox
$MyGroupBox.Location = '50,40'
$MyGroupBox.size = '500,210'
$MyGroupBox.text = "Do you want to see APPS or CONFS targeted ?"

# Create the collection of radio buttons
$RadioButton1 = New-Object System.Windows.Forms.RadioButton
$RadioButton1.Location = '40,100'
$RadioButton1.size = '360,30'
$RadioButton1.Checked = $true 
$RadioButton1.Text = "APPS"

$RadioButton2 = New-Object System.Windows.Forms.RadioButton
$RadioButton2.Location = '40,150'
$RadioButton2.size = '350,30'
$RadioButton2.Checked = $false
$RadioButton2.Text = "CONFS"

# Add an OK button
    # Thanks to J.Vierra for simplifing the use of buttons in forms
    $OKButton = new-object System.Windows.Forms.Button
    $OKButton.Location = '130,200'
    $OKButton.Size = '100,40' 
    $OKButton.Text = 'OK'
    $OKButton.DialogResult=[System.Windows.Forms.DialogResult]::OK
 
    #Add a cancel button
    $CancelButton = new-object System.Windows.Forms.Button
    $CancelButton.Location = '255,200'
    $CancelButton.Size = '100,40'
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult=[System.Windows.Forms.DialogResult]::Cancel
 
    # Add all the GroupBox controls on one line
    $MyGroupBox.Controls.AddRange(@($Radiobutton1,$RadioButton2))
 
    # Add all the Form controls on one line 
    $form.Controls.AddRange(@($MyGroupBox,$OKButton,$CancelButton,$RadioButton3))
 
 
    
    # Assign the Accept and Cancel options in the form to the corresponding buttons
    $form.AcceptButton = $OKButton
    $form.CancelButton = $CancelButton
 
    # Activate the form
    $form.Add_Shown({$form.Activate()})    
    
    # Get the results from the button click
    $dialogResult = $form.ShowDialog()

if ($dialogResult -eq "OK"){
### SWITCH APPS OR CONFS ?
    if ($RadioButton1.Checked) {
    $category = "APPS"
    }
    elseif ($RadioButton2.Checked) {
    $category = "CONFS"
}
}

#####

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



