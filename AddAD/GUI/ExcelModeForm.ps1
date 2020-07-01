### Excel mode form ###

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()


$ExcelModeForm                            = New-Object system.Windows.Forms.Form
$ExcelModeForm.ClientSize                 = '600,450'
$ExcelModeForm.Text                       = "Excel mode"
$ExcelModeForm.BackColor                  = "#f2d8ae"
$ExcelModeForm.TopMost                    = $fals

$Text                         = New-Object system.Windows.Forms.Label
$Text.text                    = "Which mode do you want to use? 

Batch mode will create as many 
users as there are Excel worksheets 
defined for users. 

Single mode will not check any additional 
sheets - will simply create one user for the first sheet"
$Text.AutoSize                = $true
$Text.width                   = 100
$Text.height                  = 100
$Text.location                = New-Object System.Drawing.Point(50,50)
$Text.Font                    = 'Bold,12'

$SingleMode                = New-Object system.Windows.Forms.Button
$SingleMode.BackColor      = "#9b9b9b"
$SingleMode.text           = "Single Mode"
$SingleMode.width          = 219
$SingleMode.height         = 53
$SingleMode.location       = New-Object System.Drawing.Point(200,226)
$SingleMode.Font           = 'Microsoft Sans Serif,15,style=Bold'
$SingleMode.Add_Click({
    Get-OneFromExcel
})

$BatchMode                      = New-Object system.Windows.Forms.Button
$BatchMode.BackColor            = "#9b9b9b"
$BatchMode.text                 = "Batch Mode"
$BatchMode.width                = 219
$BatchMode.height               = 53
$BatchMode.location             = New-Object System.Drawing.Point(200,308)
$BatchMode.Font                 = 'Microsoft Sans Serif,15,style=Bold'

$BatchMode.Add_Click({
    Get-BatchFromExcel
})

$ExcelModeForm.controls.AddRange(@($Text, $BatchMode, $SingleMode))

