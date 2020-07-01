
### AZURE CHECKUP FORM ###

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$AzureForm                       = New-Object system.Windows.Forms.Form
$AzureForm.ClientSize            = '1250,171'
$AzureForm.text                  = "Sync Azure AD"
$AzureForm.BackColor             = "#f2d8ae"
$AzureForm.TopMost               = $false

$MainEmailAzure                  = New-Object system.Windows.Forms.Label
$MainEmailAzure.text             = "Main e-mail address"
$MainEmailAzure.AutoSize         = $true
$MainEmailAzure.width            = 25
$MainEmailAzure.height           = 10
$MainEmailAzure.location         = New-Object System.Drawing.Point(50,50)
$MainEmailAzure.Font             = 'Microsoft Sans Serif,10'

$InputMainEmailAzure             = New-Object system.Windows.Forms.TextBox
$InputMainEmailAzure.multiline   = $false
$InputMainEmailAzure.width       = 191
$InputMainEmailAzure.height      = 20
$InputMainEmailAzure.location    = New-Object System.Drawing.Point(200,46)
$InputMainEmailAzure.Font        = 'Microsoft Sans Serif,10'

$CheckAzureGroupsButton                = New-Object system.Windows.Forms.Button
$CheckAzureGroupsButton.BackColor      = "#9b9b9b"
$CheckAzureGroupsButton.text           = "Check Users AzureAD Groups"
$CheckAzureGroupsButton.width          = 209
$CheckAzureGroupsButton.height         = 30
$CheckAzureGroupsButton.location       = New-Object System.Drawing.Point(30,109)
$CheckAzureGroupsButton.Font           = 'Microsoft Sans Serif,10,style=Bold'
$CheckAzureGroupsButton.ForeColor      = ""
$CheckAzureGroupsButton.Add_Click({
    Azure-SyncLookup
})

$CheckO365LicenseButton                = New-Object system.Windows.Forms.Button
$CheckO365LicenseButton.BackColor      = "#9b9b9b"
$CheckO365LicenseButton.text           = "Check Users O365 Licenses"
$CheckO365LicenseButton.width          = 209
$CheckO365LicenseButton.height         = 30
$CheckO365LicenseButton.location       = New-Object System.Drawing.Point(250,109)
$CheckO365LicenseButton.Font           = 'Microsoft Sans Serif,10,style=Bold'
$CheckO365LicenseButton.ForeColor      = ""
$CheckO365LicenseButton.Add_Click({
    O365-SyncLookup
})


$AddMFAButton                = New-Object system.Windows.Forms.Button
$AddMFAButton.BackColor      = "#9b9b9b"
$AddMFAButton.text           = "Add user to MFA group"
$AddMFAButton.width          = 209
$AddMFAButton.height         = 30
$AddMFAButton.location       = New-Object System.Drawing.Point(470,108)
$AddMFAButton.Font           = 'Microsoft Sans Serif,10,style=Bold'
$AddMFAButton.ForeColor      = ""
$AddMFAButton.Add_Click({
    Add-MFA
})

$AddE3ForNonInnleidButton                = New-Object system.Windows.Forms.Button
$AddE3ForNonInnleidButton.BackColor      = "#9b9b9b"
$AddE3ForNonInnleidButton.text           = "Add E3 license group"
$AddE3ForNonInnleidButton.width          = 209
$AddE3ForNonInnleidButton.height         = 30
$AddE3ForNonInnleidButton.location       = New-Object System.Drawing.Point(690,108)
$AddE3ForNonInnleidButton.Font           = 'Microsoft Sans Serif,10,style=Bold'
$AddE3ForNonInnleidButton.ForeColor      = ""
$AddE3ForNonInnleidButton.Add_Click({
    Add-E3
})


$CloseAzureButton                = New-Object system.Windows.Forms.Button
$CloseAzureButton.BackColor      = "#9b9b9b"
$CloseAzureButton.text           = "Close this window"
$CloseAzureButton.width          = 209
$CloseAzureButton.height         = 30
$CloseAzureButton.location       = New-Object System.Drawing.Point(920,108)
$CloseAzureButton.Font           = 'Microsoft Sans Serif,10,style=Bold'
$CloseAzureButton.ForeColor      = ""
$CloseAzureButton.Add_Click({
    $AzureForm.Close()
})

$AzureForm.controls.AddRange(@($MainEmailAzure, $AddE3ForNonInnleidButton, $InputMainEmailAzure,$CheckAzureGroupsButton,$CheckO365LicenseButton,$AddMFAButton,$CloseAzureButton))
