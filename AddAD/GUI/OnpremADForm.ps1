

### ONPREMAD FORM ###

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$OnpremADForm                    = New-Object system.Windows.Forms.Form
$OnpremADForm.ClientSize         = '482,171'
$OnpremADForm.text               = "Check OnpremAD"
$OnpremADForm.BackColor          = "#f2d8ae"
$OnpremADForm.TopMost            = $false

$UsernameOnprem                  = New-Object system.Windows.Forms.Label
$UsernameOnprem.text             = "Username (samAccountName)"
$UsernameOnprem.AutoSize         = $true
$UsernameOnprem.width            = 25
$UsernameOnprem.height           = 10
$UsernameOnprem.location         = New-Object System.Drawing.Point(38,51)
$UsernameOnprem.Font             = 'Microsoft Sans Serif,10'

$InputUsernameOnprem             = New-Object system.Windows.Forms.TextBox
$InputUsernameOnprem.multiline   = $false
$InputUsernameOnprem.width       = 191
$InputUsernameOnprem.height      = 20
$InputUsernameOnprem.location    = New-Object System.Drawing.Point(236,48)
$InputUsernameOnprem.Font        = 'Microsoft Sans Serif,10'

$CheckOnpremUser                 = New-Object system.Windows.Forms.Button
$CheckOnpremUser.BackColor       = "#9b9b9b"
$CheckOnpremUser.text            = "Check user in AD"
$CheckOnpremUser.width           = 209
$CheckOnpremUser.height          = 30
$CheckOnpremUser.location        = New-Object System.Drawing.Point(34,109)
$CheckOnpremUser.Font            = 'Microsoft Sans Serif,10,style=Bold'
$CheckOnpremUser.ForeColor       = ""

$CloseOnpremADButton             = New-Object system.Windows.Forms.Button
$CloseOnpremADButton.BackColor   = "#9b9b9b"
$CloseOnpremADButton.text        = "Close this window"
$CloseOnpremADButton.width       = 209
$CloseOnpremADButton.height      = 30
$CloseOnpremADButton.location    = New-Object System.Drawing.Point(258,108)
$CloseOnpremADButton.Font        = 'Microsoft Sans Serif,10,style=Bold'
$CloseOnpremADButton.ForeColor   = ""

$OnpremADForm.controls.AddRange(@($UsernameOnprem,$InputUsernameOnprem,$CheckOnpremUser,$CloseOnpremADButton))

